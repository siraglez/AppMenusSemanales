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
import PhotosUI

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    var recipeToEdit: Recipe?
    var newRecipeSpace: MenuSpace = .familiar
    
    @State private var name: String = ""
    @State private var instructions: String = ""
    @State private var selectedSeason: Season = .all
    @State private var selectedMealType: MealType = .lunch
    @State private var selectedAvailability: WeekAvailability = .any
    @State private var baseServings: Int = 2
    
    // Foto del plato (opcional)
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    
    @State private var isCalculatingNutrition = false
    @State private var translationConfig: TranslationSession.Configuration?
    
    // Aviso cuando no se puede calcular la nutrición (sin conexión, ...)
    @State private var showNutritionWarning = false
    @State private var pendingCategory: RecipeCategory = .other
    
    // -- VARIABLES PARA EL NUEVO INGREDIENTE --
    @State private var newIngName: String = ""
    @State private var newIngQuantity: String = ""
    @State private var newIngUnit: String = "ud"
    @State private var tempIngredients: [Ingredient] = []
    
    let units = ["ud", "g", "kg", "ml", "l", "cucharada", "pizca"]
    
    var body: some View {
        NavigationStack {
            Form {
                // SECCION 1: DATOS GENERALES
                Section("Información del plato") {
                    TextField("Nombre del plato", text: $name)
                    
                    Picker("Tipo", selection: $selectedMealType) {
                        ForEach(MealType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Estación", selection: $selectedSeason) {
                        ForEach(Season.allCases) {season in
                            Text(season.rawValue).tag(season)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Disponibilidad", selection: $selectedAvailability) {
                        ForEach(WeekAvailability.allCases) { availability in
                            Text(availability.rawValue).tag(availability)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Stepper("Cantidades para \(baseServings) \(baseServings == 1 ? "persona" : "personas")",
                    value: $baseServings, in: 1...20)
                }
                
                // SECCIÓN 2: AÑADIR INGREDIENTES
                Section("Ingredientes") {
                    HStack {
                        TextField("Ingrediente", text: $newIngName)
                            .layoutPriority(1)
                        
                        TextField("Cant.", text: $newIngQuantity)
                            .keyboardType(.decimalPad)
                            .frame(width: 50)
                        
                        Picker("", selection: $newIngUnit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 60)
                        
                        Button(action: addIngredient) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.title2)
                        }
                        .buttonStyle(.borderless)
                        .disabled(newIngName.isEmpty || newIngQuantity.isEmpty)
                        .accessibilityLabel("Añadir ingrediente")
                    }
                    
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
                
                // SECCIÓN 4: FOTO (opcional)
                Section("Foto del plato (opcional)") {
                    if let photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(8)
                            .accessibilityLabel("Foto del plato")
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label(photoData == nil ? "Añadir foto" : "Cambiar foto", systemImage: "photo")
                    }
                    
                    if photoData != nil {
                        Button(role: .destructive) {
                            photoData = nil
                            selectedPhotoItem = nil
                        } label: {
                            Label("Quitar foto", systemImage: "trash")
                        }
                    }
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
                    selectedAvailability = recipe.weekAvailability
                    baseServings = recipe.baseServings
                    tempIngredients = recipe.ingredients ?? []
                    photoData = recipe.photoData
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        photoData = prepareImageData(data)
                    }
                }
            }
            .translationTask(translationConfig) { session in
                await save(session: session)
                translationConfig = nil
            }
            .alert("No se pudo calcular la nutrición", isPresented: $showNutritionWarning) {
                Button("Guardar igualmente") { persist(nutrition: nil) }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("No hemos podido obtener la información nutricional (puede que no haya conexión a internet). Puedes guardar la receta ahora y editarlas más tarde para calcularla, o cancelar.")
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
        let quantityString = newIngQuantity.replacingOccurrences(of: ",", with: ".")
        let quantity = Double(quantityString) ?? 0.0
        let newIngredient = Ingredient(name: newIngName, quantity: quantity, unit: newIngUnit)
        tempIngredients.append(newIngredient)
        newIngName = ""
        newIngQuantity = ""
    }
    
    // Reduce el tamaño de la foto antes de guardarla (máx 1024 px, JPEG comprimido)
    func prepareImageData(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let maxSide: CGFloat = 1024
        let size = image.size
        let scale = min(1, maxSide / max(size.width, size.height))
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: 0.8)
    }
    
    func save(session: TranslationSession? = nil) async {
        let result = await NutritionService.calculateNutrition(
            for: tempIngredients,
            translationSession: session
        )
        pendingCategory = NutritionService.detectCategory(from: tempIngredients)
        isCalculatingNutrition = false
        
        // Si hubi fallo de conexión o no se calculó ningún ingrediente, avisamos
        if result.networkError || result.fetched == 0 {
            showNutritionWarning = true
        } else {
            persist(nutrition: result.info)
        }
    }
    
    // Guarda la receta (con nutrición si la hay, o sin ella si se guardó "igualmente")
    func persist(nutrition: NutritionInfo?) {
        if let recipe = recipeToEdit {
            recipe.name = name
            recipe.instructions = instructions
            recipe.mealType = selectedMealType
            recipe.season = selectedSeason
            recipe.weekAvailability = selectedAvailability
            recipe.baseServings = baseServings
            recipe.ingredients = tempIngredients
            recipe.calories = nutrition?.calories
            recipe.proteins = nutrition?.proteins
            recipe.carbs = nutrition?.carbs
            recipe.fats = nutrition?.fats
            recipe.category = pendingCategory
            recipe.photoData = photoData
        } else {
            let newRecipe = Recipe(
                name: name,
                ingredients: tempIngredients,
                instructions: instructions,
                mealType: selectedMealType,
                season: selectedSeason
            )
            newRecipe.weekAvailability = selectedAvailability
            newRecipe.baseServings = baseServings
            newRecipe.calories = nutrition?.calories
            newRecipe.proteins = nutrition?.proteins
            newRecipe.carbs = nutrition?.carbs
            newRecipe.fats = nutrition?.fats
            newRecipe.category = pendingCategory
            newRecipe.space = newRecipeSpace
            newRecipe.photoData = photoData
            context.insert(newRecipe)
        }
        dismiss()
    }
}
