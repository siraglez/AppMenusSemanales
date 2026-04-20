//
//  PreferenceWarning.swift
//  AppMenusSemanales
//
//  Created by Sira González-Madroño on 20/4/26.
//
//  Define los tres tipos de aviso que puede generar una receta según las preferencias del usuario.
//  Se usa en WeeklyPlanView para mostrar los avisos en las tarjetas del menú.
 
import SwiftUI
 
enum PreferenceWarning: Identifiable {
    case allergen([String])      // Rojo   → alérgeno, no se debería ver (filtrado en el generador)
    case intolerance([String])   // Naranja → intolerancia, adaptar la receta
    case disliked([String])      // Amarillo → no gusta, aviso suave
 
    // Identifiable: usamos el mensaje como id único
    var id: String { message }
 
    var color: Color {
        switch self {
        case .allergen:    return .red
        case .intolerance: return .orange
        case .disliked:    return Color(red: 0.8, green: 0.6, blue: 0.0)
        }
    }
 
    var icon: String {
        switch self {
        case .allergen:    return "exclamationmark.triangle.fill"
        case .intolerance: return "exclamationmark.circle.fill"
        case .disliked:    return "hand.thumbsdown.fill"
        }
    }
 
    var message: String {
        switch self {
        case .allergen(let items):
            return "Alérgeno: \(items.joined(separator: ", "))"
        case .intolerance(let items):
            return "Adaptar: usar versión sin \(items.joined(separator: ", "))"
        case .disliked(let items):
            return "No te gusta: \(items.joined(separator: ", "))"
        }
    }
}
 
// MARK: - Función global para calcular los avisos de una receta
// Se llama desde WeeklyPlanView pasando las preferencias del usuario
func preferenceWarnings(for recipe: Recipe, preferences: UserPreferences?) -> [PreferenceWarning] {
    guard let prefs = preferences else { return [] }
 
    let ingredientNames = recipe.ingredients.map { $0.name.lowercased() }
    var result: [PreferenceWarning] = []
 
    // 1. Alergias
    let allergenMatches = prefs.allergies.filter { allergen in
        ingredientNames.contains { $0.contains(allergen.lowercased()) }
    }
    if !allergenMatches.isEmpty {
        result.append(.allergen(allergenMatches))
    }
 
    // 2. Intolerancias
    let intoleranceMatches = prefs.intolerances.filter { intolerance in
        ingredientNames.contains { $0.contains(intolerance.lowercased()) }
    }
    if !intoleranceMatches.isEmpty {
        result.append(.intolerance(intoleranceMatches))
    }
 
    // 3. Preferencias (no le gusta)
    let dislikeMatches = prefs.dislikes.filter { dislike in
        ingredientNames.contains { $0.contains(dislike.lowercased()) }
    }
    if !dislikeMatches.isEmpty {
        result.append(.disliked(dislikeMatches))
    }
 
    return result
}
