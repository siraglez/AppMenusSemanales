//
//  OnboardingPreferencesView.swift
//  AppMenusSemanales
//
//  Created by Sira González-Madroño
//
//  Pantalla que aparece UNA SOLA VEZ justo después del registro.
//  Permite al usuario configurar sus alergias/intolerancias/preferencias antes de empezar.
// Puede omitirse y configurarse después en Perfil.

 
import SwiftUI
 
struct OnboardingPreferencesView: View {
    // Cuando se pone a true, la app pasa a mostrar ContentView
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)
                    
                    Text("¿Tienes alguna alergia o preferencia?")
                        .font(.title2).bold()
                        .multilineTextAlignment(.center)
                    
                    Text("Configúralas ahora para que el generador de menús las tenga en cuenta. Siempre podrás editarlas desde tu perfil.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.vertical, 24)
                
                PreferencesEditorView()
            }
            .navigationTitle("Mis Preferencias")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Omitir") { didCompleteOnboarding = true }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continuar") { didCompleteOnboarding = true }
                        .bold()
                }
            }
        }
    }
}
 
