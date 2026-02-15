//
//  AppMenusSemanalesApp.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// El arranque de la app

import SwiftUI
import SwiftData

@main
struct AppMenusSemanalesApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView()
            } else {
                LoginView()
            }
        }
        // Crear el archivo de base de datos automáticamente
        .modelContainer(for: [Recipe.self, UserProfile.self, WeeklyMenu.self])
    }
}
