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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Crear el archivo de base de datos automáticamente
        .modelContainer(for: [Recipe.self, UserProfile.self])
    }
}
