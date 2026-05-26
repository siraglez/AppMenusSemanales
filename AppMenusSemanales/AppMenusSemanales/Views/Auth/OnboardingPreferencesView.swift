//
//  OnboardingPreferencesView.swift
//  AppMenusSemanales
//
//  Created by Sira González-Madroño
//
//  Pantalla que aparece UNA SOLA VEZ justo después del registro.
//  Permite al usuario configurar sus alergias/intolerancias/preferencias
//  antes de entrar a la app. Puede omitirse y configurarse después en Perfil.
//
//  FLUJO:
//  RegisterView → (isLoggedIn = true, needsPreferencesSetup = true)
//  → AppMenusSemanalesApp muestra esta vista
//  → Usuario pulsa "Continuar" u "Omitir"
//  → (needsPreferencesSetup = false) → se muestra ContentView
 
import SwiftUI
 
struct OnboardingPreferencesView: View {
    
    // Esta variable controla si se muestra esta pantalla o ContentView
    // Cuando se pone a false, AppMenusSemanalesApp mostrará ContentView
    @AppStorage("needsPreferencesSetup") var needsPreferencesSetup: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // ── Cabecera ──
                VStack(spacing: 12) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)
                    
                    Text("¿Tienes alguna alergia o preferencia?")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("Configúralas ahora para que el generador de menús las tenga en cuenta. Siempre podrás editarlas desde tu perfil.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.vertical, 24)
                
                // ── Editor de preferencias (vista reutilizable) ──
                PreferencesEditorView()
            }
            .navigationTitle("Mis Preferencias")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Botón "Omitir": entra a la app sin configurar nada
                ToolbarItem(placement: .cancellationAction) {
                    Button("Omitir") {
                        needsPreferencesSetup = false
                    }
                    .foregroundStyle(.secondary)
                }
                
                // Botón "Continuar": guarda lo introducido y entra a la app
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continuar") {
                        needsPreferencesSetup = false
                    }
                    .bold()
                }
            }
        }
    }
}
 
