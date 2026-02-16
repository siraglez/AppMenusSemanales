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
