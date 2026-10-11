//
//  FixedAssignment.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 07/06/2026.
//
// Receta fija: El usuario asigna una receta concreta a un día y una ingesta
// Al generar el menú, esa receta se coloca siempre en ese hueco automáticamente

import Foundation
import SwiftData

@Model
class FixedAssignment {
    var id: UUID = UUID()
    var dayName: String = ""
    var mealType: String = ""
    var spaceRaw: String = MenuSpace.familiar.rawValue
    var space: MenuSpace {
        get { MenuSpace(rawValue: spaceRaw) ?? .familiar }
        set { spaceRaw = newValue.rawValue }
    }
    
    // Si se borra la receta, la asignación queda sin receta en vez de romperse
    @Relationship(deleteRule: .nullify, inverse: \Recipe.fixedAssignments)
    var recipe: Recipe?
    
    init(dayName: String, mealType: String, recipe: Recipe?) {
        self.id = UUID()
        self.dayName = dayName
        self.mealType = mealType
        self.recipe = recipe
    }
}
