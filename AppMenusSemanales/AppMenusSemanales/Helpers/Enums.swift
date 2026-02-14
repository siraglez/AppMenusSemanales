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
