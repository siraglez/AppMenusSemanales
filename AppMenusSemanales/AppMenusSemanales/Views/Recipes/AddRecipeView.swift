//
//  AddRecipeView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño
//
// Formulario para crear receta

import SwiftUI
import SwiftData
import Translation

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    var recipeToEdit: Recipe?
    
    @State private var name: String = ""
    @State private var instructions: String = ""
    @State private var selectedSeason: Season = .all
    @State private var selectedMealType: MealType = .lunch
    @State private var selectedAvailability: WeekAvailability = .any
    @State private var baseServings: Int = 2
    
    @State private var isCalculatingNutrition = false
    @State private var translationConfig: TranslationSession.Configuration?
    
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
                    
                    // Selector de Estación
                    Picker("Estación", selection: $selectedSeason) {
                        ForEach(Season.allCases) { season in
                            Text(season.rawValue).tag(season)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Selector de disponibilidad (entre semana o fin de semana)
                    Picker("Disponibilidad", selection: $selectedAvailability) {
                        ForEach(WeekAvailability.allCases) { availability in
                            Text(availability.rawValue).tag(availability)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // Para cuántas personas son las cantidades de los ingredientes
                    Stepper("Cantidades para \(baseServings) \(baseServings == 1 ? "persona" : "personas")",
                            value: $baseServings, in: 1...20)
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
                        
                        Picker("", selection: $newIngUnit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu) // Se abre como menú flotante
                        .labelsHidden()
                        .frame(width: 60) // Limitamos su ancho
                        
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
                    Button(action: startSaveProcess) {
                        if isCalculatingNutrition {
                            HStack(spacing: 6) {
                                ProgressView().scaleEffect(0.8)
                                Text("Calculando...")
                            }
                        } else {
                            Text("Guardar")
                        }
                    }
                    .disabled(name.isEmpty || tempIngredients.isEmpty || isCalculatingNutrition)
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
            .translationTask(translationConfig) { session in
                await save(session: session)
                translationConfig = nil
            }
        }
    }
    
    func startSaveProcess() {
        isCalculatingNutrition = true
        translationConfig = TranslationSession.Configuration(
            source: Locale.Language(identifier: "es"),
            target: Locale.Language(identifier: "en")
        )
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
    
    func save(session: TranslationSession? = nil) async {
        let nutrition = await NutritionService.calculateNutrition(
            for: tempIngredients,
            translationSession: session
        )
        let detectedCategory = NutritionService.detectCategory(from: tempIngredients)
        
        if let recipe = recipeToEdit {
            recipe.name = name
            recipe.instructions = instructions
            recipe.mealType = selectedMealType
            recipe.season = selectedSeason
            recipe.weekAvailability = selectedAvailability
            recipe.ingredients = tempIngredients
            recipe.calories = nutrition.calories
            recipe.proteins = nutrition.proteins
            recipe.carbs    = nutrition.carbs
            recipe.fats     = nutrition.fats
            recipe.category = detectedCategory
        } else {
            let newRecipe = Recipe(
                name: name,
                ingredients: tempIngredients,
                instructions: instructions,
                mealType: selectedMealType,
                season: selectedSeason
            )
            newRecipe.weekAvailability = selectedAvailability
            newRecipe.calories = nutrition.calories
            newRecipe.proteins = nutrition.proteins
            newRecipe.carbs    = nutrition.carbs
            newRecipe.fats     = nutrition.fats
            newRecipe.category = detectedCategory
            context.insert(newRecipe)
        }
        
        isCalculatingNutrition = false
        dismiss()
    }
}
