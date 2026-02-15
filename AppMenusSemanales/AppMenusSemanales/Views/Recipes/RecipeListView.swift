//
//  RecipeListView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// Lista de recetas

import SwiftUI
import SwiftData

struct RecipeListView: View {
    // @Query lee la base de datos y actualiza la lista sola
    @Query(sort: \Recipe.name) var recipes: [Recipe]
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
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
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
