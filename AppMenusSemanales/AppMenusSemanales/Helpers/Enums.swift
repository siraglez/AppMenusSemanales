//
//  Enums.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//
// Para definir el tipo de comida y las estaciones


import Foundation
import SwiftUI

// Definir si es Comida o Cena
enum MealType: String, CaseIterable, Codable, Identifiable {
    case lunch = "Comida"
    case dinner = "Cena"
    case both = "Ambos" // Por si alguna receta vale para los dos tipos
    
    var id: String { self.rawValue }
}

// Definir la Estación (Importante para el algoritmo de filtrado)
enum Season: String, CaseIterable, Codable, Identifiable {
    case all = "Todo el año"
    case summer = "Verano"
    case winter = "Invierno"
    
    var id: String { self.rawValue }
}

// Definir el tipo de comida
enum RecipeCategory: String, CaseIterable, Codable, Identifiable {
    case meat = "Carne"
    case fish = "Pescado"
    case legume = "Legumbre"
    case vegetable = "Verdura"
    case eggs = "Huevos"
    case pastaRice = "Pasta/Arroz"
    case other = "Otro"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .meat: return "meat"
        case .fish: return "fish"
        case .legume: return "legume"
        case .vegetable: return "carrot"
        case .eggs: return "egg"
        case .pastaRice: return "pasta"
        case .other: return "questionmark.circle"
        }
    }
    
    var isCustomIcon: Bool {
        switch self {
        case .meat, .pastaRice, .legume, .eggs: return true
        default: return false
        }
    }
}
