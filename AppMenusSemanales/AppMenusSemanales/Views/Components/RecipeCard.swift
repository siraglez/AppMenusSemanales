//
//  RecipeCard.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//
// Tarjeta reutilizable para recetas

import SwiftUI
import UIKit

struct RecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 12) {
            // Miniatura solo si la receta tiene foto
            if let data = recipe.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 54, height: 54)
                    .clipped()
                    .cornerRadius(8)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.headline)
                
                HStack {
                    Text(recipe.mealType.rawValue)
                        .font(.caption)
                        .padding(5)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    
                    Text(recipe.season.rawValue)
                        .font(.caption)
                        .padding(5)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(6)
                    
                    CategoryLabel(category: recipe.category)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// Vista auxiliar que muestra el icono de categoría, soportando tanto SF Symbols como assets personalizados
struct CategoryLabel: View {
    let category: RecipeCategory
    
    var body: some View {   // ← AQUÍ estaba el error: era "vdy", debe ser "body"
        HStack(spacing: 4) {
            if category.isCustomIcon {
                Image(category.icon)  // Asset propio
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(.primary)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: category.icon)  // SF Symbol
                    .accessibilityHidden(true)
            }
            Text(category.rawValue)
        }
        .font(.caption)
        .padding(5)
        .background(Color.green.opacity(0.1))
        .cornerRadius(6)
    }
}
