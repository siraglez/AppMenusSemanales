//
//  UserPreferences.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//
// Modelo para guardar alergias, intolerancias y preferencias del usuario
//
//  TRES NIVELES DE RESTRICCIÓN:
//  - Alergia     → la receta se EXCLUYE completamente del menú generado
//  - Intolerancia → la receta se INCLUYE pero con aviso de adaptación (ej: sin lactosa)
//  - No me gusta  → aviso SUAVE, el usuario decide si incluirla o no

import Foundation
import SwiftData

@Model
class UserPreferences {
    
    // Alergias: ingredientes peligrosos → receta descartada del menú
    var allergies: [String]
    
    // Intolerancias: ingredientes problemáticos → receta incluida con aviso de adaptación
    var intolerances: [String]
    
    // Preferencias: ingredientes que no gustan → aviso suave
    var dislikes: [String]
    
    init() {
        self.allergies    = []
        self.intolerances = []
        self.dislikes     = []
    }
}
 
