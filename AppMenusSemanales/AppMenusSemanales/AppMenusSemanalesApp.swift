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
// DATOS: dos almacenes
// - Personal: sincronizado con el iCloud del usuario
// - Familiar: compartido con la familia

import SwiftUI
import SwiftData

@main
struct AppMenusSemanalesApp: App {
    @AppStorage("appAppearance") var appAppearanceRaw: String = AppAppearance.system.rawValue
    
    // Los dos almacenes de datos (personal y familiar)
    @State private var stores = DataStores()
    
    var body: some Scene {
        WindowGroup {
            RootContentView()
                .environment(stores)
                .preferredColorScheme(AppAppearance(rawValue: appAppearanceRaw)?.colorScheme)
        }
        // Por defecto toda la app usa el almacén personal
        // Las pantallas que dependen del espacio cambian de almacén en ContentView
        .modelContainer(stores.personal)
    }
}
