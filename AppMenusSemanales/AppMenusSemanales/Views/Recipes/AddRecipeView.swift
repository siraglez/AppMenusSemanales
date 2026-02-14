//
//  AddRecipeView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// Formulario para crear receta

import SwiftUI
import SwiftData

struct AddRecipeView: View {
    // Para cerrar la ventana al guardar
    @Environment(\.dismiss) var dismiss
    // Para guardar en la base de datos
    @Environment(\.modelContext) var context
    
    // Si se recibe una receta, estamos EDITANDO. Sino, es NUEVA
    var recipeToEdit: Recipe?
    
    // Variables temporales del formulario
    @State private var name: String = ""
    @State private var ingredients: String = ""
    @State private var instructions: String = ""
    @State private var selectedSeason: Season = .all
    @State private var selectedMealType: MealType = .lunch
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Datos principales")) {
                    TextField("Nombre de la receta", text: $name)
                    
                    Picker("Tipo de Comida", selection: $selectedMealType) {
                        ForEach(MealType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Estación", selection: $selectedSeason) {
                        ForEach(Season.allCases) { season in
                            Text(season.rawValue).tag(season)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Detalles") {
                    TextField("Ingredientes (separados por comas)", text: $ingredients, axis: .vertical)
                    TextField("Instrucciones de la receta", text: $instructions, axis: .vertical)
                }
            }
            .navigationTitle(recipeToEdit == nil ? "Nueva Receta" : "Editar Receta")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveRecipe()
                    }
                    .disabled(name.isEmpty) // No deja guardar sin nombre
                }
            }
            .onAppear {
                // Si estamos editando, cargamos los datos existentes
                if let recipe = recipeToEdit {
                    name = recipe.name
                    ingredients = recipe.ingredients
                    instructions = recipe.instructions
                    selectedMealType = recipe.mealType
                    selectedSeason = recipe.season
                }
            }
        }
    }
    
    func saveRecipe() {
        if let recipe = recipeToEdit {
            // Modo EDICIón: Actualizar la receta existente
            recipe.name = name
            recipe.ingredients = ingredients
            recipe.instructions = instructions
            recipe.mealType = selectedMealType
            recipe.season = selectedSeason
        } else {
            // Crear la receta con los datos del formulario
            let newRecipe = Recipe(
                name: name,
                ingredients: ingredients,
                instructions: instructions,
                mealType: selectedMealType,
                season: selectedSeason
            )
            // Insertar en la base de datos
            context.insert(newRecipe)
        }
        // Cerrar la ventana
        dismiss()
    }
}
