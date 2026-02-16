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
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    var recipeToEdit: Recipe?
    
    @State private var name: String = ""
    @State private var instructions: String = ""
    @State private var selectedSeason: Season = .all
    @State private var selectedMealType: MealType = .lunch
    
    // --- VARIABLES PARA EL NUEVO INGREDIENTE ---
    @State private var newIngName: String = ""
    @State private var newIngQuantity: String = ""
    @State private var newIngUnit: String = "ud"
    @State private var tempIngredients: [Ingredient] = []
    
    let units = ["ud", "g", "kg", "ml", "L", "cucharada", "pizca"]
    
    var body: some View {
        NavigationStack {
            Form {
                // SECCIÓN 1: DATOS GENERALES
                Section("Información del plato") {
                    TextField("Nombre del plato", text: $name)
                    
                    // Selector de Comida/Cena (Segmented)
                    Picker("Tipo", selection: $selectedMealType) {
                        ForEach(MealType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Selector de Estación (CORREGIDO: Ahora es Segmented también)
                    Picker("Estación", selection: $selectedSeason) {
                        ForEach(Season.allCases) { season in
                            Text(season.rawValue).tag(season)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // SECCIÓN 2: AÑADIR INGREDIENTES
                Section("Ingredientes") {
                    // Formulario en línea corregido
                    HStack {
                        TextField("Ingrediente", text: $newIngName)
                            .layoutPriority(1) // Da prioridad al nombre para que ocupe espacio
                        
                        TextField("Cant.", text: $newIngQuantity)
                            .keyboardType(.decimalPad)
                            .frame(width: 50) // Ancho fijo para la cantidad
                        
                        // CORRECCIÓN 1: Estilo Menú para que no tape el botón
                        Picker("", selection: $newIngUnit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu) // Se abre como menú flotante
                        .labelsHidden()
                        .frame(width: 60) // Limitamos su ancho
                        
                        // CORRECCIÓN 2: ButtonStyle Borderless para que funcione el clic
                        Button(action: addIngredient) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.title2)
                        }
                        .buttonStyle(.borderless) // ¡CRUCIAL! Permite hacer clic sin seleccionar la fila
                        .disabled(newIngName.isEmpty || newIngQuantity.isEmpty)
                    }
                    
                    // Lista de ingredientes añadidos
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
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
                    tempIngredients = recipe.ingredients
                }
            }
        }
    }
    
    func addIngredient() {
        // Truco: Reemplazamos coma por punto por si el usuario usa teclado español
        let quantityString = newIngQuantity.replacingOccurrences(of: ",", with: ".")
        let quantity = Double(quantityString) ?? 0.0
        
        let newIngredient = Ingredient(name: newIngName, quantity: quantity, unit: newIngUnit)
        tempIngredients.append(newIngredient)
        
        // Limpiamos campos y ponemos el foco en nombre (opcional)
        newIngName = ""
        newIngQuantity = ""
    }
    
    func save() {
        if let recipe = recipeToEdit {
            recipe.name = name
            recipe.instructions = instructions
            recipe.mealType = selectedMealType
            recipe.season = selectedSeason
            recipe.ingredients = tempIngredients
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
