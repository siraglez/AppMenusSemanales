//
//  SettingsView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 18/06/2026.
//
// Pantalla de ajustes generales de la aplicación
// Se accede desde el botón del engranaje en el perfil

import SwiftUI
import SwiftData

// Tema de la app (claro / oscuro / según el sistema)
enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "Sistema"
    case light = "Claro"
    case dark = "Oscuro"
    
    var id: String { rawValue }
    
    // nil = deja que mande el sistema
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct SettingsView: View {
    @Environment(\.modelContext) var context
    
    @Query var allMenus: [WeeklyMenu]
    @Query var extraItems: [ExtraItem]
    
    // Ajustes guardados en el dispositivo
    @AppStorage("appAppearance") var appAppearanceRaw: String = AppAppearance.system.rawValue
    @AppStorage("dinersCount") var dinersCount: Int = 2
    
    // Estados para las alertas de confirmación
    @State private var showDeleteMenusAlert = false
    @State private var showClearListAlert = false
    
    var body: some View {
        Form {
            // ── Apariencia ──
            Section("Apariencia") {
                Picker("Tema", selection: $appAppearanceRaw) {
                    ForEach(AppAppearance.allCases) { appearance in Text(appearance.rawValue).tag(appearance.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // ── Menú y compra ──
            Section {
                Stepper("Comensales por defecto: \(dinersCount)", value: $dinersCount, in: 1...20)
            } header: {
                Text("Menú y Compra")
            } footer: {
                Text("Número de personas que se usa para calcular las cantidades de la lista de la compra.")
            }
            
            // ── Gestión de datos ──
            Section {
                Button(role: .destructive) {
                    showDeleteMenusAlert = true
                } label: {
                    Label("Borrar todos los menús", systemImage: "calendar.badge.minus")
                }
                Button(role: .destructive) {
                    showClearListAlert = true
                } label: {
                    Label("Vaciar la lista de la compra", systemImage: "cart.badge.minus")
                }
            } header: {
                Text("Gestión de datos")
            } footer: {
                Text("Estas acciones no borran tus recetas, solo los menús generados o los productos de la lista.")
            }
            
            // ── Acerca de ──
            Section("Acerca de") {
                HStack {
                    Text("Versión")
                    Spacer()
                    Text(appVersion).foregroundStyle(.secondary)
                }
                HStack {
                    Text("Autora")
                    Spacer()
                    Text("Sira González-Madroño").foregroundStyle(.secondary)
                }
                Text("App de planificación de menús semanales desarrollada como Trabajo de Fin de Grado.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
        // Confirmación: borrar menús
        .alert("¿Borrar todos los menús?", isPresented: $showDeleteMenusAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Borrar", role: .destructive) { deleteAllMenus() }
        } message: {
            Text("Se eliminarán todos los menús generados de todas las semanas. Tus recetas no se borrarán.")
        }
        // Confirmación: vaciar lista
        .alert("¿Vaciar la lista de la compra?", isPresented: $showClearListAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Vaciar", role: .destructive) { clearShoppingList() }
        } message: {
            Text("Se eliminarán  los productos añadidos manualmente y se desmarcarán todos los elementos")
        }
    }
    
    // Versión de la app leída del Info.plist
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return version
    }
    
    // MARK: - Acciones de datos
    func deleteAllMenus() {
        for menu in allMenus {
            context.delete(menu)
        }
    }
    
    func clearShoppingList() {
        // Borrar los productos manuales
        for item in extraItems {
            context.delete(item)
        }
        // Desmarcar todos los checks guardados
        UserDefaults.standard.removeObject(forKey: "savedShoppingChecks")
    }
}
