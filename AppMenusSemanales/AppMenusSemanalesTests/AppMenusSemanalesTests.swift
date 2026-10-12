//
//  AppMenusSemanalesTests.swift
//  AppMenusSemanalesTests
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// Pruebas unitarias de la lógica de negocio:
// - Generador de menús (MenuGenerator)
// - Detección de categoría (NutritionService.detectCategory)
// - Avisos de preferencias y alergias (preferenceWarnings)

import Testing
import Foundation
@testable import AppMenusSemanales

// MARK: Helpers para crear datos de prueba

/// Crea una receta en memoria con unos valores nutricionales de ejemplo
private func makeRecipe(_ name: String,
                        category: RecipeCategory = .other,
                        meal: MealType = .both,
                        season: Season = .all,
                        availability: WeekAvailability = .any,
                        ingredients: [Ingredient] = []) -> Recipe {
    let r = Recipe(name: name, ingredients: ingredients, instructions: "", mealType: meal, season: season)
    r.category = category
    r.weekAvailability = availability
    // Valores nutricionales de ejemplo para que el algoritmo de macros funcione
    r.calories = 400
    r.proteins = 20
    r.carbs = 50
    r.fats = 15
    return r
}

// MARK: Tests del generador de menús

struct MenuGeneratorTests {
    @Test func devuelveErrorSiNoHayRecetas() {
        let result = MenuGenerator.generateWeekMenu(recipes: [], forWeekOf: Date())
        guard case .failure(.notEnoughRecipes) = result else {
            Issue.record("Se esperaba el error notEnoughRecipes al no haber recetas")
            return
        }
    }
    
    @Test func generaSieteDiasConComidaYCena() {
        let recipes = (1...14).map { makeRecipe("Receta \($0)") }
        let result = MenuGenerator.generateWeekMenu(recipes: recipes, forWeekOf: Date())
        
        guard case .success(let menu) = result else {
            Issue.record("Debería generar un menú con suficientes recetas")
            return
        }
        #expect(menu.count == 7)
        #expect(menu.allSatisfy {$0.lunch != nil && $0.dinner != nil })
    }
    
    @Test func colocaLaRecetaFijaEnSuDiaEIngesta() {
        let recipes = (1...14).map { makeRecipe("Receta \($0)") }
        let pizza = makeRecipe("Pizza", meal: .dinner)
        let fija = FixedAssignment(dayName: "Viernes",
                                   mealType: MealType.dinner.rawValue,
                                   recipe: pizza)
        
        let result = MenuGenerator.generateWeekMenu(recipes: recipes + [pizza], forWeekOf: Date(), fixedAssignments: [fija])
        
        guard case .success(let menu) = result else {
            Issue.record("Debería generar el menú")
            return
        }
        let viernes = menu.first { $0.dayName == "Viernes" }
        #expect(viernes?.dinner?.id == pizza.id)
    }
    
    @Test func excluyeLasRecetasConUnAlergeno() {
        var recetas = (1...14).map {
            makeRecipe("Segura \($0)",
                       ingredients: [Ingredient(name: "arroz", quantity: 100, unit: "g")])
        }
        let conPollo = makeRecipe("Pollo asado",
                                  ingredients: [Ingredient(name: "pollo", quantity: 200, unit: "g")])
        recetas.append(conPollo)
        
        let result = MenuGenerator.generateWeekMenu(
            recipes: recetas,
            forWeekOf: Date(),
            allergies: ["pollo"]
        )
        
        guard case .success(let menu) = result else {
            Issue.record("Deberçia generar el menú")
            return
        }
        let usadas = menu.flatMap { [$0.lunch?.id, $0.dinner?.id] }.compactMap { $0 }
        #expect(!usadas.contains(conPollo.id))
    }
    
    @Test func avisaSiNoHayRecetasParaElFinDeSemana() {
        // Todas las recetas son solo "entre semana": el fin de semana no se puede cubrir
        let recipes = (1...14).map { makeRecipe("Receta \($0)", availability: .weekday) }
        let result = MenuGenerator.generateWeekMenu(recipes: recipes, forWeekOf: Date())
        
        guard case .failure(.notEnoughForAvailability) = result else {
            Issue.record("Debería fallar por disponibilidad de fin de semana")
            return
        }
    }
}

// MARK: Tests de detección de categoría

struct DetectCategoryTests {
    
    @Test func detectaCarne() {
        let ings = [Ingredient(name: "pollo", quantity: 200, unit: "g")]
        #expect(NutritionService.detectCategory(from: ings) == .meat)
    }
    
    @Test func laLegumbreTienePrioridadSobreLaCarne() {
        // Lentejas con chorizo -> debe clasificarse como legumbre
        let ings = [
            Ingredient(name: "lentejas", quantity: 200, unit:"g"),
            Ingredient(name: "chorizo", quantity: 50, unit: "g")
        ]
        #expect(NutritionService.detectCategory(from: ings) == .legume)
    }
    
    @Test func detectaPastaOArroz() {
        let ings = [Ingredient(name: "espagueti", quantity: 100, unit:"g")]
        #expect(NutritionService.detectCategory(from: ings) == .pastaRice)
    }
    
    @Test func sinCoincidenciasEsOtro() {
        let ings = [Ingredient(name: "ingrediente raro", quantity: 1, unit: "ud")]
        #expect(NutritionService.detectCategory(from: ings) == .other)
    }
}

// MARK:Tests de avisos de preferencias

struct PreferenceWarningTests {
    
    @Test func laIntoleranciaALaLactosaDetectaElQueso() {
        let prefs = UserPreferences()
        prefs.intolerances = ["Lactosa"]
        let receta = makeRecipe("Pizza",
                                ingredients: [Ingredient(name: "queso", quantity: 100, unit: "g")])
        
        let avisos = preferenceWarnings(for: receta, preferences: prefs)
        let hayIntolerancia = avisos.contains {
            if case .intolerance = $0 { return true } else { return false }
        }
        #expect(hayIntolerancia)
    }
    
    @Test func detectaUnAlimentoQueNoGusta() {
        let prefs = UserPreferences()
        prefs.dislikes = ["Cebolla"]
        let receta = makeRecipe("Sopa",
                                ingredients: [Ingredient(name: "cebolla", quantity: 50, unit: "g")])
        
        let avisos = preferenceWarnings(for: receta, preferences: prefs)
        let hayDisgusto = avisos.contains {
            if case .disliked = $0 { return true } else { return false }
        }
        #expect(hayDisgusto)
    }
    
    @Test func noAvisasSiNoHayCoincidencias() {
        let prefs = UserPreferences()
        prefs.allergies = ["Marisco"]
        let receta = makeRecipe("Ensalada",
                                ingredients: [Ingredient(name: "lechuga", quantity: 100, unit: "g")])
        
        #expect(preferenceWarnings(for: receta, preferences: prefs).isEmpty)
    }
}
