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
    
    static func generateWeekMenu(recipes: [Recipe], season: Season = .all) -> [WeeklyMenu] {
        var menu: [WeeklyMenu] = []
        let days = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
        
        // 1. Filtramos por la estación seleccionada (si no hay, usamos todas)
        var availableRecipes = recipes.filter { recipe in
            season == .all || recipe.season == season || recipe.season == .all
        }
        
        // SEGURIDAD: Si el filtro de estación deja la lista vacía, usamos TODAS las recetas
        if availableRecipes.isEmpty {
            availableRecipes = recipes
        }
        
        // Si aún así no hay recetas, devolvemos menú vacío
        if availableRecipes.isEmpty { return [] }
        
        // 2. Separamos Comidas y Cenas
        var lunches = availableRecipes.filter { $0.mealType == .lunch || $0.mealType == .both }.shuffled()
        var dinners = availableRecipes.filter { $0.mealType == .dinner || $0.mealType == .both }.shuffled()
        
        // FALLBACK: Si no hay comidas, usamos lo que haya (cenas) y viceversa
        if lunches.isEmpty { lunches = availableRecipes.shuffled() }
        if dinners.isEmpty { dinners = availableRecipes.shuffled() }
        
        // 3. Generamos los días
        for (index, day) in days.enumerated() {
            // Usamos el operador módulo (%) para repetir recetas si hay pocas
            let lunchRecipe = lunches[index % lunches.count]
            let dinnerRecipe = dinners[index % dinners.count]
            
            let dailyMenu = WeeklyMenu(day: day, lunch: lunchRecipe, dinner: dinnerRecipe)
            menu.append(dailyMenu)
        }
        
        return menu
    }
}
