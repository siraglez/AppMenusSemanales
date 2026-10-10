//
//  AppMenusSemanalesApp.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//
// El arranque de la app
//
// NAVEGACIÓN INICIAL:
// - Primera vez (didCompleteOnboarding == false) -> OnboardingPreferencesView
// - A partir de entonces -> ContentView
//
// La app no tiene cuentas de usuario: todos los datos son locales.
// (El inicio de sesión con Apple se añadirá más adelante).

import SwiftUI
import SwiftData

@main
struct AppMenusSemanalesApp: App {
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    @AppStorage("appAppearance") var appAppearanceRaw: String = AppAppearance.system.rawValue
    
    var body: some Scene {
        WindowGroup {
            Group {
                if didCompleteOnboarding {
                    ContentView()
                } else {
                    OnboardingPreferencesView()
                }
            }
            .preferredColorScheme(AppAppearance(rawValue: appAppearanceRaw)?.colorScheme)
        }
        .modelContainer(for: [
            Recipe.self,
            WeeklyMenu.self,
            ExtraItem.self,
            UserPreferences.self,
            FixedAssignment.self,
            FamilyMember.self
        ])
    }
}
