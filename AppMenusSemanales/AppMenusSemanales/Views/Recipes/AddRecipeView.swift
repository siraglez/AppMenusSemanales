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
    
    // Variables para los ingredientes
    @State private var newIngName: String = ""
    @State private var newIngQuantity: String = ""
    @State private var newIngUnit: String = "ud"
    @State private var tempIngredients: [Ingredient] = []
    
    let units = ["ud", "g", "kg", "ml", "L", "cucharada", "cucharadita", "taza", "pizca"]
    
    var body: some View {
            NavigationStack {
                Form {
                    // SECCIÓN 1: DATOS GENERALES
                    Section("Información del plato") {
                        TextField("Nombre del plato", text: $name)
                        Picker("Tipo", selection: $selectedMealType) {
                            ForEach(MealType.allCases) { type in Text(type.rawValue).tag(type) }
                        }
                        .pickerStyle(.segmented)
                        
                        Picker("Estación", selection: $selectedSeason) {
                            ForEach(Season.allCases) { season in Text(season.rawValue).tag(season) }
                        }
                    }
                    
                    // SECCIÓN 2: AÑADIR INGREDIENTES (LA NOVEDAD)
                    Section("Ingredientes") {
                        // Formulario pequeño para añadir uno
                        HStack {
                            TextField("Ingrediente (ej: Tomate)", text: $newIngName)
                            TextField("Cant.", text: $newIngQuantity)
                                .keyboardType(.decimalPad)
                                .frame(width: 60)
                            
                            Picker("", selection: $newIngUnit) {
                                ForEach(units, id: \.self) { unit in Text(unit).tag(unit) }
                            }
                            .labelsHidden()
                            
                            Button(action: addIngredient) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.blue)
                                    .font(.title2)
                            }
                            .disabled(newIngName.isEmpty || newIngQuantity.isEmpty)
                        }
                        
                        // Lista de lo añadido
                        List {
                            ForEach(tempIngredients) { ingredient in
                                HStack {
                                    Text(ingredient.name)
                                    Spacer()
                                    Text("\(ingredient.quantity.formatted()) \(ingredient.unit)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .onDelete { indexSet in
                                tempIngredients.remove(atOffsets: indexSet)
                            }
                        }
                    }
                    
                    // SECCIÓN 3: INSTRUCCIONES
                    Section("Preparación") {
                        TextField("Pasos a seguir...", text: $instructions, axis: .vertical)
                            .lineLimit(4...10)
                    }
                }
                .navigationTitle(recipeToEdit == nil ? "Nueva Receta" : "Editar Receta")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guardar") { save() }
                            .disabled(name.isEmpty || tempIngredients.isEmpty)
                    }
                }
                .onAppear {
                    if let recipe = recipeToEdit {
                        name = recipe.name
                        instructions = recipe.instructions
                        selectedMealType = recipe.mealType
                        selectedSeason = recipe.season
                        // IMPORTANTE: Cargamos los ingredientes existentes
                        tempIngredients = recipe.ingredients
                    }
                }
            }
        }
        
        func addIngredient() {
            // Convertimos el texto de cantidad a número (Double)
            // Usamos la localización actual para entender comas o puntos
            let quantity = Double(newIngQuantity.replacingOccurrences(of: ",", with: ".")) ?? 0.0
            
            let newIngredient = Ingredient(name: newIngName, quantity: quantity, unit: newIngUnit)
            tempIngredients.append(newIngredient)
            
            // Limpiamos campos para el siguiente
            newIngName = ""
            newIngQuantity = ""
        }
        
        func save() {
            if let recipe = recipeToEdit {
                recipe.name = name
                recipe.instructions = instructions
                recipe.mealType = selectedMealType
                recipe.season = selectedSeason
                recipe.ingredients = tempIngredients // Actualizamos la lista
            } else {
                let newRecipe = Recipe(
                    name: name,
                    ingredients: tempIngredients,
                    instructions: instructions,
                    mealType: selectedMealType,
                    season: selectedSeason
                )
                context.insert(newRecipe)
            }
            dismiss()
        }
    }
