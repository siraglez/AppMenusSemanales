//
//  Untitled.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño
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
    var mealTypeRaw: String
    var seasonRaw: String
    var categoryRaw: String
    
    // Disponibilidad semanal
    var weekAvailabilityRaw: String = WeekAvailability.any.rawValue
    
    // Datos nutricionales
    var calories: Double?
    var proteins: Double?
    var carbs: Double?
    var fats: Double?
    
    // Convertir los String guardados a los Enums para usarlos fácil en código
    var mealType: MealType {
        get { MealType(rawValue: mealTypeRaw) ?? .lunch }
        set { mealTypeRaw = newValue.rawValue }
    }
    
    var season: Season {
        get { Season(rawValue: seasonRaw) ?? .all }
        set { seasonRaw = newValue.rawValue }
    }
    
    var category: RecipeCategory {
        get { RecipeCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
    
    var weekAvailability: WeekAvailability {
        get { WeekAvailability(rawValue: weekAvailabilityRaw) ?? .any }
        set { weekAvailabilityRaw = newValue.rawValue }
    }
    
    init(name: String, ingredients: [Ingredient] = [], instructions: String = "", mealType: MealType = .lunch, season: Season = .all) {
        self.id = UUID()
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
        self.mealTypeRaw = mealType.rawValue
        self.seasonRaw = season.rawValue
        self.categoryRaw = RecipeCategory.other.rawValue
        self.weekAvailabilityRaw = WeekAvailability.any.rawValue
    }
}
