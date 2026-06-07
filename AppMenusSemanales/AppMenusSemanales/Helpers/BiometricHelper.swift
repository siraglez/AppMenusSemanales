//
//  BiometricHelper.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//

// Para poder usar Face ID / Touch ID para iniciar sesión una vez tengas cuenta

import Foundation
import LocalAuthentication

class BiometricHelper {
    // Comprueba si el móvil tien Face Id / Touch ID y pide permiso
    static func authenticateUser(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // 1. Comprobar si el hardware permite biometría
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identifícate para entrar en tu menú"
            
            // 2. Lanzar el escáner de cara/huella
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                
                // Volver al hilo principal para actualizar la UI
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil) // Éxito
                    } else {
                        completion(false, "No se pudo reconocer la cara")
                    }
                }
            }
        } else {
            // No hay Face ID disponible o el usuario no tiene código puesto
            completion(false, "Tu dispositivo no tiene Face ID configurado")
        }
    }
}
