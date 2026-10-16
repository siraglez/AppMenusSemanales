//
//  AppLockView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 16/10/2026.
//
// Envuelve toda la app y aplica el bloqueo con Face ID si está activado en Ajustes

import SwiftUI

struct RootContentView: View {
    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding: Bool = false
    @AppStorage("appLockEnabled") var appLockEnabled: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isUnlocked = false
    @State private var isAuthenticating = false
    
    var body: some View {
        ZStack {
            // Contenido normal de la app
            Group {
                if didCompleteOnboarding {
                    ContentView()
                } else {
                    OnboardingPreferencesView()
                }
            }
            
            // Capa de bloqueo por encima (solo si está activado y aún no se ha desbloqueado)
            if appLockEnabled && !isUnlocked {
                LockScreen(isAuthenticating: isAuthenticating, onUnlock: unlock)
            }
        }
        .onAppear {
            // Al arrancar: si hay bloqueo, pedir autenticación; si no, entrar directamente
            if appLockEnabled {
                unlock()
            } else {
                isUnlocked = true
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // Al volver a la app, si está bloqueada, volver a pedir Face ID
                if appLockEnabled && !isUnlocked {
                    unlock()
                }
            case .background:
                // Al salir de la app, volver a bloquear
                if appLockEnabled {
                isUnlocked = false
                }
            default:
                break
            }
        }
    }
    
    func unlock() {
        guard !isAuthenticating else { return }  // Evita pedirlo dos veces a la vez
        isAuthenticating = true
        Task {
            let ok = await BiometricHelper.authenticate(reason: "Desbloquea AppMenusSemanales")
            isAuthenticating = false
            if ok { isUnlocked = true }
        }
    }
}

// Pantalla que se ve cuando la app está bloqueada
struct LockScreen: View {
    let isAuthenticating: Bool
    let onUnlock: () -> Void
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.secondary)
                
                Text("App bloqueada")
                    .font(.title2.bold())
                
                Text("Usa \(BiometricHelper.biometricTypeName()) para desbloquear")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(action: onUnlock) {
                    Label("Desbloquear", systemImage: "faceid")
                        .padding(.horizontal)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isAuthenticating)
            }
            .padding()
        }
    }
}
