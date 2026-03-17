//
//  MenuGenerator.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// Algoritmo inteligente

import Foundation
import SwiftData

// Resultado del generador: éxito con el menú, o fallo por falta de recetas
enum MenuGenerationError: Error {
    case notEnoughRecipes
}

class MenuGenerator {

    static func generateWeekMenu(
        recipes: [Recipe],
        forWeekOf date: Date,
        season: Season = .all,
        excludedRecipeIDs: Set<UUID> = []   // IDs de la semana anterior
    ) -> Result<[WeeklyMenu], MenuGenerationError> {

        let days = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        // 1. Filtrar por estación
        var available = recipes.filter {
            season == .all || $0.season == season || $0.season == .all
        }
        if available.isEmpty { available = recipes }

        // 2. Excluir recetas de la semana anterior
        let candidates = available.filter { !excludedRecipeIDs.contains($0.id) }

        // 3. Separar en pools y mezclar
        var lunchPool  = candidates.filter { $0.mealType == .lunch  || $0.mealType == .both }.shuffled()
        var dinnerPool = candidates.filter { $0.mealType == .dinner || $0.mealType == .both }.shuffled()

        if lunchPool.isEmpty  { lunchPool  = candidates.shuffled() }
        if dinnerPool.isEmpty { dinnerPool = candidates.shuffled() }

        // 4. Seleccionar 7 comidas y 7 cenas SIN repetir ninguna receta entre sí
        var usedIDs = Set<UUID>()
        var lunches: [Recipe] = []
        var dinners: [Recipe] = []

        for recipe in lunchPool {
            if lunches.count == 7 { break }
            if !usedIDs.contains(recipe.id) {
                lunches.append(recipe)
                usedIDs.insert(recipe.id)
            }
        }

        for recipe in dinnerPool {
            if dinners.count == 7 { break }
            if !usedIDs.contains(recipe.id) {   // evita solaparse con comidas
                dinners.append(recipe)
                usedIDs.insert(recipe.id)
            }
        }

        // 5. Comprobar si hay suficientes tras deduplicar
        guard lunches.count == 7, dinners.count == 7 else {
            return .failure(.notEnoughRecipes)
        }

        // 6. Construir el menú día a día
        let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        ) ?? date

        var menu: [WeeklyMenu] = []
        for (index, day) in days.enumerated() {
            let dayDate = calendar.date(byAdding: .day, value: index, to: startOfWeek) ?? Date()
            menu.append(WeeklyMenu(dayName: day, date: dayDate, lunch: lunches[index], dinner: dinners[index]))
        }

        return .success(menu)
    }
}
