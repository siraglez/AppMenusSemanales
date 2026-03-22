//
//  Enums.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
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
        case .meat: return "🥩"
        case .fish: return "🐟"
        case .legume: return "🫘"
        case .vegetable: return "🥦"
        case .eggs: return "🥚"
        case .pastaRice: return "🍝"
        case .other: return "🍽️"
        }
    }
}
