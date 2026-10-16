//
//  BiometricHelper.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 16/10/2026.
//
// Pequeña utilidad para el bloqueo de la app con Face ID / Touch ID

import Foundation
import LocalAuthentication

enum BiometricHelper {
    // ¿El dispositivo tiene Face ID / Touch ID configurado y disponible?
    static func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    // Nombre del tipo de biometría, para mostrarlo en los textos ("Face ID / "Touch ID")
    static func biometricTypeName() -> String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "biometría"
        }
    }
    
    // Pide autenticación. Devuelve true si se desbloquea correctamente
    // Usamos deviceOwnerAuthentication para que, si Face ID falla, se pueda recurrir al código del dispositivo
    static func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        let policy: LAPolicy = .deviceOwnerAuthentication
        guard context.canEvaluatePolicy(policy, error: nil) else { return false }
        do {
            return try await context.evaluatePolicy(policy, localizedReason: reason)
        } catch {
            return false
        }
    }
}
