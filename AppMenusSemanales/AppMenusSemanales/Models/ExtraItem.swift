//
//  ExtraItem.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//
// Para poder agregar otros elementos a la lista de la compra a parte de lo automático

import Foundation
import SwiftData

@Model
class ExtraItem {
    var id: UUID = UUID()
    var name: String = ""
    var quantity: Double = 0
    var unit: String = ""
    var dateAdded: Date = Date()
    
    init(name: String, quantity: Double, unit: String) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.dateAdded = Date()
    }
}
