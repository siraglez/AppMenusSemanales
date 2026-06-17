//
//  AppMenusSemanalesApp.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//
// El arranque de la app
//
//  LÓGICA DE NAVEGACIÓN INICIAL:
//  ┌─────────────────────────────────────────────────────┐
//  │ ¿isLoggedIn?                                        │
//  │   NO  → LoginView                                   │
//  │   SÍ  → ¿needsPreferencesSetup?                     │
//  │           SÍ → OnboardingPreferencesView (1ª vez)   │
//  │           NO → ContentView (app normal)             │
//  └─────────────────────────────────────────────────────┘
//
//  needsPreferencesSetup se activa a true en RegisterView
//  y se desactiva a false en OnboardingPreferencesView

import SwiftUI
import SwiftData

@main
struct AppMenusSemanalesApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("needsPreferencesSetup") var needsPreferencesSetup: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                if needsPreferencesSetup {
                    OnboardingPreferencesView()
                } else {
                    ContentView()
                }
            } else {
                LoginView()
            }
        }
        // Crear el archivo de base de datos automáticamente
        .modelContainer(for: [
            Recipe.self,
            UserProfile.self,
            WeeklyMenu.self,
            ExtraItem.self,
            UserPreferences.self,
            FixedAssignment.self,
            FamilyMember.self
        ])
    }
}
