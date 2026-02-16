//
//  Ingredient.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 16/2/26.
//

// Para poder poner cantidades en los ingredientes

import Foundation
import SwiftData

@Model
class Ingredient {
    var id: UUID
    var name: String
    var quantity: Double
    var unit: String
    
    init(name: String, quantity: Double, unit: String) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}
