//
//  Untitled.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// Tabla de base de datos para recetas


import Foundation
import SwiftData

@Model
class Recipe {
    var id: UUID
    var name: String
    var instructions: String
    @Relationship(deleteRule: .cascade) var ingredients: [Ingredient] = []
    var mealTypeRaw: String // Se guardará el valor 'raw' del Enum
    var seasonRaw: String // Se guardará el valor 'raw' del Enum
    var imageData: Data? // Para guardar foto en el futuro
    
    // Convertir los String guardados a los Enums para usarlos fácil en código
    var mealType: MealType {
        get { MealType(rawValue: mealTypeRaw) ?? .lunch }
        set { mealTypeRaw = newValue.rawValue }
    }
    
    var season: Season {
        get { Season(rawValue: seasonRaw) ?? .all }
        set { seasonRaw = newValue.rawValue }
    }
    
    init(name: String, ingredients: [Ingredient] = [], instructions: String = "", mealType: MealType = .lunch, season: Season = .all) {
        self.id = UUID()
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
        self.mealTypeRaw = mealType.rawValue
        self.seasonRaw = season.rawValue
    }
}
