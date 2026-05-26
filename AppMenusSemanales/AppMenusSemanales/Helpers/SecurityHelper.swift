//
//  SecurityHelper.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//

// Encriptación de contraseña

import Foundation
import CryptoKit

struct SecurityHelper {
    static func hashPassword(_ password: String) -> String {
        guard let data = password.data(using: .utf8) else { return "" }
        let hashed = SHA256.hash(data: data)
        // Convertir el hash en una cadena de text legible
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
