//
//  FixedRecipesEditorView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 07/06/2026.
//
// Pantalla para asignar recetas fijas a días e ingestas concretos
// Se accede desde el perfil, igual que las preferencias alimentarias
//
// Para cada día se puede elegir una receta fija para la Comida y/o la Cena
// "Ninguna" deja ese hueco libre para que el generador lo rellene normalmente

import SwiftUI
import SwiftData

struct FixedRecipesEditorView: View {
    @Environment(\.modelContext) var context
    @Query(sort: \Recipe.name) var allRecipes: [Recipe]
    @Query var fixedAssignments: [FixedAssignment]
    
    let days = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    
    var body: some View {
        Form {
            Section {
                Text("Asigna una receta a un día y una ingesta para que el menú la coloque siempre ahí automáticamente")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if allRecipes.isEmpty {
                Section {
                    Text("Primero añade recetas para poder fijarlas.")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(days, id: \.self) { day in
                    Section(day) {
                        fixedPicker(day: day, meal: .lunch)
                        fixedPicker(day: day, meal: .dinner)
                    }
                }
            }
        }
    }
    
    // Selector de receta fija para un día + ingesta
    @ViewBuilder
    func fixedPicker(day: String, meal: MealType) -> some View {
        Picker(meal.rawValue, selection: selectionBinding(day: day, meal: meal)) {
            Text("Ninguna").tag(UUID?.none)
            ForEach(allRecipes) { recipe in
                Text(recipe.name).tag(UUID?.some(recipe.id))
            }
        }
    }
    
    // Receta fija actual para ese hueco (si la hay)
    func currentRecipe(day: String, meal: MealType) -> Recipe? {
        fixedAssignments.first {
            $0.dayName == day && $0.mealType == meal.rawValue
        }?.recipe
    }
    
    // Binding que crea, actualiza o borra la asignación según lo que elija el usuario
    func selectionBinding(day: String, meal: MealType) -> Binding<UUID?> {
        Binding(
            get: { currentRecipe(day: day, meal: meal)?.id },
            set: { newID in setFixed(day: day, meal: meal, recipeID: newID) }
        )
    }
    
    func setFixed(day: String, meal: MealType, recipeID: UUID?) {
        let existing = fixedAssignments.first {
            $0.dayName == day && $0.mealType == meal.rawValue
        }
        
        if let recipeID, let recipe = allRecipes.first(where: { $0.id == recipeID }) {
            // Elegida una receta concreta
            if let existing {
                existing.recipe = recipe
            } else {
                context.insert(FixedAssignment(
                    dayName: day, mealType: meal.rawValue, recipe: recipe))
            }
        } else {
            // "Ninguna" → borrar la asignación si existía
            if let existing { context.delete(existing) }
        }
    }
}
