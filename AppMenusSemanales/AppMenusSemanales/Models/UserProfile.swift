//
//  UserProfile.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// Modelo de usuario

import Foundation
import SwiftData

@Model
class UserProfile {
    var name: String
    var email: String
    var registerDate: Date
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
        self.registerDate = Date()
    }
}
