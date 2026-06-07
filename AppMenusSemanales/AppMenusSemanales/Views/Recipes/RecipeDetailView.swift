//
//  RecipeDetailView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//
// Ver los detalles de las recetas de la lista al pinchar en ellas

import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Bindable var recipe: Recipe // Bindable permite detectar cambios si editamos
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State private var showEditSheet = false

    // Preferencias del usuario para mostrar avisos en el detalle
    @Query var userPreferences: [UserPreferences]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Etiquetas
                HStack {
                    Label(recipe.mealType.rawValue, systemImage: "fork.knife")
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Label(recipe.season.rawValue, systemImage: "sun.max")
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    
                    HStack(spacing: 4) {
                        if recipe.category.isCustomIcon {
                            Image(recipe.category.icon)           // asset propio
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                        } else {
                            Image(systemName: recipe.category.icon)  // SF Symbol
                        }
                        Text(recipe.category.rawValue)
                    }
                    .font(.caption)
                    .padding(8)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }

                // Avisos de preferencias (alergia / intolerancia / no me gusta)
                // Se calculan con la función de PreferenceWarning.swift y se muestran
                // en recuadros de color: rojo (alérgeno), naranja (adaptar), gris (no gusta)
                let warnings = preferenceWarnings(for: recipe, preferences: userPreferences.first)
                if !warnings.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(warnings) { warning in
                            Label(warning.message, systemImage: warning.icon)
                                .font(.caption)
                                .foregroundStyle(warning.color)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(warning.color.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                
                if let calories = recipe.calories {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Información Nutricional")
                            .font(.headline)
                        Text("Valores aproximados para la receta completa")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 0) {
                            NutrientBadge(label: "Calorías", value: calories, unit: "kcal", color: .orange)
                            NutrientBadge(label: "Proteínas", value: recipe.proteins ?? 0, unit: "g", color: .blue)
                            NutrientBadge(label: "Carbohidratos", value: recipe.carbs ?? 0, unit: "g", color: .yellow)
                            NutrientBadge(label: "Grasas", value: recipe.fats ?? 0, unit: "g", color: .red)
                        }
                        .padding()
                        .background(Color(.systemGroupedBackground))
                        .cornerRadius(12)
                    }
                }
                
                Divider()
                
                Text("Ingredientes")
                    .font(.headline)
                ForEach(recipe.ingredients) { ingredient in
                    HStack {
                        Text("• " + ingredient.name)
                        Spacer()
                        Text("\(ingredient.quantity.formatted()) \(ingredient.unit)")
                            .foregroundStyle(.secondary)
                    }
                }
                if recipe.ingredients.isEmpty {
                    Text("Sin ingredientes registrados").foregroundStyle(.secondary)
                }

                Divider()
                
                Text("Instrucciones")
                    .font(.headline)
                Text(recipe.instructions.isEmpty ? "Sin instrucciones" : recipe.instructions)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .toolbar {
            Button("Editar") {
                showEditSheet = true
            }
        }
        .sheet(isPresented: $showEditSheet) {
            // Reutilizar la vista de añadir pasándole la receta actual
            AddRecipeView(recipeToEdit: recipe)
        }
    }
}

struct NutrientBadge: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.0f", value))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
