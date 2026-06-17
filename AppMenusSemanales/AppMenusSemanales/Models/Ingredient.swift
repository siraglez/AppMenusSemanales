//
//  Ingredient.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño
//

// Para poder poner cantidades en los ingredientes

import Foundation
import SwiftData

@Model
class Ingredient {
    var id: UUID = UUID()
    var name: String = ""
    var quantity: Double = 0
    var unit: String = ""
    
    // Inversa de Recipe.ingredients necesaria para ClouKit
    var recipe: Recipe?
    
    init(name: String, quantity: Double, unit: String) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}
