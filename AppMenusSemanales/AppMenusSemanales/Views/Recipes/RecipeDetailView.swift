//
//  RecipeDetailView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// Ver los detalles de las recetas de la lista al pinchar en ellas

import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Bindable var recipe: Recipe // Bindable permite detectar cambios si editamos
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State private var showEditSheet = false
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
