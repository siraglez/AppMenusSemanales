//
//  RecipeListView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//
// Lista de recetas

import SwiftUI
import SwiftData

struct RecipeListView: View {
    // @Query lee la base de datos y actualiza la lista sola
    @Query(sort: \Recipe.name) var recipes: [Recipe]
    
    @Query var allMenus: [WeeklyMenu]
    
    @Environment(\.modelContext) var context
    
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        VStack(alignment: .leading) {
                            Text(recipe.name).font(.headline)
                            HStack {
                                Text(recipe.mealType.rawValue)
                                    .font(.caption)
                                    .padding(5)
                                    .background(Color.blue.opacity(0.1))
                                Text(recipe.season.rawValue)
                                    .font(.caption)
                                    .padding(5)
                                    .background(Color.orange.opacity(0.1))
                                // Icono de categoría (SF Symbol o asset propio)
                                CategoryLabel(category: recipe.category)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let recipeToDelete = recipes[index]
                        
                        //Quitar la receta de cualquier menú que la use (dejar el hueco vacío)
                        for menu in allMenus {
                            if menu.lunch?.id == recipeToDelete.id { menu.lunch = nil }
                            if menu.dinner?.id == recipeToDelete.id { menu.dinner = nil }
                        }
                        
                        // Ahora ya es seguro borrar la receta
                        context.delete(recipes[index])
                    }
                }
            }
            .navigationTitle("Mis Recetas")
            .toolbar {
                Button("Añadir", systemImage: "plus") {
                    showAddSheet = true
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddRecipeView()
            }
        }
    }
}
