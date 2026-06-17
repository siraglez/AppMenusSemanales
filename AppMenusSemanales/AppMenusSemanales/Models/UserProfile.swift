//
//  UserProfile.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//
// Modelo de usuario

import Foundation
import SwiftData

@Model
class UserProfile {
    var name: String = ""
    var surname: String = ""
    var email: String = ""
    var password: String = ""  // Hash SHA-256
    var registerDate: Date = Date()
    
    init(name: String, surname: String, email: String, password: String) {
        self.name = name
        self.surname = surname
        self.email = email
        self.password = password
        self.registerDate = Date()
    }
}
