//
//  FamilyMember.swift
//  AppMenusSemanales
//
//  Created by Sira González-Madroño 
//

import Foundation
import SwiftData

@Model
class FamilyMember {
    var id: UUID
    var name: String
    var role: String           // "Principal", "Familiar"
    var preferences: UserPreferences?
    
    init(name: String, role: String) {
        self.id = UUID()
        self.name = name
        self.role = role
    }
}
