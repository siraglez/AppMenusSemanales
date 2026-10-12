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
    @Query(sort: \Recipe.name) var recipes: [Recipe]
    @Query var allMenus: [WeeklyMenu]
    
    @Environment(\.modelContext) var context
    
    @AppStorage("currentSpace") var currentSpaceRaw: String = MenuSpace.familiar.rawValue
    var currentSpace: MenuSpace { MenuSpace(rawValue: currentSpaceRaw) ?? .familiar }
    
    @State private var showAddSheet = false
    
    // Recetas del espacio activo
    var spaceRecipes: [Recipe] { recipes.filter { $0.space == currentSpace} }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Selector de espacio (familiar / personal)
                Picker("Espacio", selection: $currentSpaceRaw) {
                    ForEach(MenuSpace.allCases) { space in
                        Text(space.rawValue).tag(space.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                List {
                    if spaceRecipes.isEmpty {
                        Text("No hay recetas en el espacio \(currentSpace.rawValue.lowercased()). Añade una con el botón +.")
                            .foregroundStyle(.secondary)
                    }
                    
                    ForEach(spaceRecipes) { recipe in
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
                                    CategoryLabel(category: recipe.category)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let recipeToDelete = spaceRecipes[index]
                            
                            // Quitar la receta de cualquier menú que la use (dejar el hueco vacío)
                            for menu in allMenus {
                                if menu.lunch?.id == recipeToDelete.id { menu.lunch = nil }
                                if menu.dinner?.id == recipeToDelete.id { menu.dinner = nil }
                            }
                            
                            context.delete(recipeToDelete)
                        }
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
                // La receta nueva se crea en el espacio activo
                AddRecipeView(newRecipeSpace: currentSpace)
            }
        }
    }
}
