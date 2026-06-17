//
//  FamilyMember.swift
//  AppMenusSemanales
//
//  Created by Sira González-Madroño 
//
// Miembro de la unidad familiar (preparado para la fase de grupos familiares)

import Foundation
import SwiftData

@Model
class FamilyMember {
    var id: UUID = UUID()
    var name: String = ""
    var role: String = ""  // "Principal", "Familiar"
    
    @Relationship(inverse: \UserPreferences.member)
    var preferences: UserPreferences?
    
    init(name: String, role: String) {
        self.id = UUID()
        self.name = name
        self.role = role
    }
}
