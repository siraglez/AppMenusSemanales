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
    var id: UUID = UUID()
    var dayName: String = "" // Lunes, Martes...
    var date: Date = Date() // Para saber de qué semana es
    var spaceRaw: String = MenuSpace.familiar.rawValue // Espacio al que pertenece este menú (familiar o personal)
    var space: MenuSpace {
        get { MenuSpace(rawValue: spaceRaw) ?? .familiar }
        set { spaceRaw = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .nullify, inverse: \Recipe.menusAsLunch)
    var lunch: Recipe?
    @Relationship(deleteRule: .nullify, inverse: \Recipe.menusAsDinner)
    var dinner: Recipe?
    
    init(dayName: String, date: Date, lunch: Recipe?, dinner: Recipe?) {
        self.id = UUID()
        self.dayName = dayName
        self.date = date
        self.lunch = lunch
        self.dinner = dinner
    }
}
