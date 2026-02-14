//
//  MenuGenerator.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// Algoritmo inteligente

import Foundation
import SwiftData

class MenuGenerator {
    // Función principal: Genera un menú aleatorio
    static func generateWeekMenu(recipes: [Recipe], season: Season = .all) -> [WeeklyMenu] {
        var menu: [WeeklyMenu] = []
        let days = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
        
        // 1. Filtrar recetas por estación (si no es 'todas')
        let availableRecipes = recipes.filter { recipe in
            if season == .all { return true }
            return recipe.season == season || recipe.season == .all
        }
        
        // Separar comidas y cenas
        let lunches = availableRecipes.filter { $0.mealType == .lunch || $0.mealType == .both }.shuffled()
        let dinners = availableRecipes.filter { $0.mealType == .dinner || $0.mealType == .both }.shuffled()
        
        // 2. Algoritmo simple de asignación
        for (index, day) in days.enumerated() {
            // Intentamos coger una receta única usando el módulo (%) para no salirnos del array
            let lunchRecipe = lunches.isEmpty ? nil : lunches[index % lunches.count]
            let dinnerRecipe = dinners.isEmpty ? nil : dinners[index % dinners.count]
            
            if let lunch = lunchRecipe, let dinner = dinnerRecipe {
                let dailyMenu = WeeklyMenu(day: day, lunch: lunch, dinner: dinner)
                menu.append(dailyMenu)
            }
        }
        
        return menu
    }
}
