//
//  MenuGenerator.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// Algoritmo inteligente con patrón mediterráneo y optimización de macros

import Foundation
import SwiftData

enum MenuGenerationError: Error {
    case notEnoughRecipes
}

class MenuGenerator {

    // Patrón mediterráneo: 7 comidas + 7 cenas
    // Total: Carne x3, Pescado x3, Legumbre x2, Verdura x2, Pasta/Arroz x2, Huevos x1, Otro x1
    private static let lunchPattern: [RecipeCategory]  = [.meat, .fish, .legume, .pastaRice, .meat, .fish, .vegetable]
    private static let dinnerPattern: [RecipeCategory] = [.fish, .vegetable, .meat, .eggs, .pastaRice, .legume, .other]

    static func generateWeekMenu(
        recipes: [Recipe],
        forWeekOf date: Date,
        season: Season = .all,
        excludedRecipeIDs: Set<UUID> = []
    ) -> Result<[WeeklyMenu], MenuGenerationError> {

        let days = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        // 1. Filtrar por estación
        var available = recipes.filter {
            season == .all || $0.season == season || $0.season == .all
        }
        if available.isEmpty { available = recipes }

        // 2. Excluir recetas de la semana anterior
        let candidates = available.filter { !excludedRecipeIDs.contains($0.id) }

        // 3. Separar por tipo de comida y mezclar
        var lunchPool  = candidates.filter { $0.mealType == .lunch  || $0.mealType == .both }.shuffled()
        var dinnerPool = candidates.filter { $0.mealType == .dinner || $0.mealType == .both }.shuffled()

        if lunchPool.isEmpty  { lunchPool  = candidates.shuffled() }
        if dinnerPool.isEmpty { dinnerPool = candidates.shuffled() }

        guard lunchPool.count >= 7, dinnerPool.count >= 7 else {
            return .failure(.notEnoughRecipes)
        }

        // 4. Seleccionar recetas siguiendo el patrón + optimización de macros
        var usedIDs = Set<UUID>()
        var accumulated = NutritionInfo()
        var lunches: [Recipe] = []
        var dinners: [Recipe] = []

        for category in lunchPattern {
            guard let recipe = pickBest(from: lunchPool, category: category,
                                        usedIDs: usedIDs, accumulated: accumulated) else {
                return .failure(.notEnoughRecipes)
            }
            lunches.append(recipe)
            usedIDs.insert(recipe.id)
            accumulated.add(recipe)
        }

        for category in dinnerPattern {
            guard let recipe = pickBest(from: dinnerPool, category: category,
                                        usedIDs: usedIDs, accumulated: accumulated) else {
                return .failure(.notEnoughRecipes)
            }
            dinners.append(recipe)
            usedIDs.insert(recipe.id)
            accumulated.add(recipe)
        }

        // 5. Construir el menú día a día
        let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        ) ?? date

        var menu: [WeeklyMenu] = []
        for (index, day) in days.enumerated() {
            let dayDate = calendar.date(byAdding: .day, value: index, to: startOfWeek) ?? Date()
            menu.append(WeeklyMenu(dayName: day, date: dayDate,
                                   lunch: lunches[index], dinner: dinners[index]))
        }

        return .success(menu)
    }

    // MARK: - Selección inteligente

    private static func pickBest(from pool: [Recipe], category: RecipeCategory,
                                  usedIDs: Set<UUID>, accumulated: NutritionInfo) -> Recipe? {
        // Primero intentamos con la categoría correcta
        let categoryMatches = pool.filter { !usedIDs.contains($0.id) && $0.category == category }

        if !categoryMatches.isEmpty {
            return pickByMacros(from: categoryMatches, accumulated: accumulated)
        }

        // Fallback: cualquier receta no usada
        let anyAvailable = pool.filter { !usedIDs.contains($0.id) }
        return pickByMacros(from: anyAvailable, accumulated: accumulated)
    }

    private static func pickByMacros(from candidates: [Recipe], accumulated: NutritionInfo) -> Recipe? {
        guard !candidates.isEmpty else { return nil }

        // Sin datos acumulados aún → devolvemos la primera (ya mezclada)
        guard accumulated.calories > 0 else { return candidates.first }

        // Objetivos dieta mediterránea: 20% proteína, 50% carbos, 30% grasa
        let totalCals = accumulated.calories
        let proteinGap = 0.20 - (accumulated.proteins * 4) / totalCals
        let carbGap    = 0.50 - (accumulated.carbs    * 4) / totalCals
        let fatGap     = 0.30 - (accumulated.fats     * 9) / totalCals

        return candidates.min { a, b in
            let scoreA = macroScore(a, pGap: proteinGap, cGap: carbGap, fGap: fatGap)
            let scoreB = macroScore(b, pGap: proteinGap, cGap: carbGap, fGap: fatGap)
            return scoreA < scoreB
        }
    }

    // Puntuación: qué tan bien complementa esta receta los macros acumulados
    private static func macroScore(_ recipe: Recipe, pGap: Double, cGap: Double, fGap: Double) -> Double {
        guard let cals = recipe.calories, cals > 0,
              let p = recipe.proteins, let c = recipe.carbs, let f = recipe.fats else {
            return Double.infinity // Sin datos nutricionales → última opción
        }
        let pR = (p * 4) / cals
        let cR = (c * 4) / cals
        let fR = (f * 9) / cals

        return abs(pR - max(0, pGap)) + abs(cR - max(0, cGap)) + abs(fR - max(0, fGap))
    }
}

// Extensión para acumular macros fácilmente
private extension NutritionInfo {
    mutating func add(_ recipe: Recipe) {
        calories += recipe.calories ?? 0
        proteins += recipe.proteins ?? 0
        carbs    += recipe.carbs    ?? 0
        fats     += recipe.fats     ?? 0
    }
}
