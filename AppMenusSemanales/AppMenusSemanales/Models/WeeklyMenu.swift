//
//  WeeklyMenu.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//
// Tabla para guardar qué se come cada día

import Foundation
import SwiftData

@Model
class WeeklyMenu {
    var id: UUID
    var dayName: String // Lunes, Martes...
    var date: Date // Para saber de qué semana es
    
    @Relationship(deleteRule: .nullify) var lunch: Recipe?
    @Relationship(deleteRule: .nullify) var dinner: Recipe?
    
    init(dayName: String, date: Date, lunch: Recipe, dinner: Recipe) {
        self.id = UUID()
        self.dayName = dayName
        self.date = date
        self.lunch = lunch
        self.dinner = dinner
    }
}
