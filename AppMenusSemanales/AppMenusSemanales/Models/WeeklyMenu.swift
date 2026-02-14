//
//  WeeklyMenu.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// Tabla para guardar qué se come cada día

import Foundation
import SwiftData

@Model
class WeeklyMenu {
    var id: UUID
    var day: String // Lunes, Martes...
    var lunch: Recipe
    var dinner: Recipe
    var date: Date // Para saber de qué semana es
    
    init(day: String, lunch: Recipe, dinner: Recipe) {
        self.id = UUID()
        self.day = day
        self.lunch = lunch
        self.dinner = dinner
        self.date = Date()
    }
}
