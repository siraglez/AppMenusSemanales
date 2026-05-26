//
//  PreferenceWarning.swift
//  AppMenusSemanales
//
//  Created by Sira González-Madroño 
//
//  Define los tres tipos de aviso que puede generar una receta según las preferencias del usuario.
//  Se usa en WeeklyPlanView para mostrar los avisos en las tarjetas del menú.
 
import SwiftUI
 
// MARK: - Diccionario de intolerancias
// Relaciona cada intolerancia con los ingredientes que la contienen
// Se usa tanto en PreferenceWarning (avisos visuales) como en MenuGenerator (filtro de alérgenos)
let intoleranceIngredients: [String: [String]] = [
    "lactosa":   ["leche", "queso", "nata", "mantequilla", "yogur", "crema",
                  "lácteo", "lacteo", "mozzarella", "parmesano", "manchego",
                  "gouda", "cheddar", "requesón", "cuajada", "bechamel",
                  "lonchas", "rallado", "feta", "brie", "camembert"],
    "gluten":    ["harina", "pan", "pasta", "trigo", "cebada", "centeno",
                  "avena", "macarrón", "espagueti", "fideos", "lasaña",
                  "galleta", "rebozado", "empanado", "sémola", "cuscús",
                  "pita", "tortilla de trigo", "couscous"],
    "fructosa":  ["manzana", "pera", "mango", "miel", "sirope", "agave",
                  "fructosa", "zumo", "mermelada", "ketchup", "cebolla",
                  "puerro", "espárrago", "alcachofa"],
    "sorbitol":  ["ciruela", "melocotón", "albaricoque", "cereza", "nectarina",
                  "manzana", "pera", "chicle", "caramelo", "menta"],
    "histamina": ["atún", "sardina", "anchoas", "boquerones", "arenque",
                  "embutido", "jamón", "chorizo", "salami", "salchichón",
                  "bacon", "pepperoni", "vinagre", "tomate", "espinaca",
                  "berenjena", "queso curado", "conserva", "marisco",
                  "gambas", "langostino"],
    "fodmap":    ["cebolla", "ajo", "puerro", "manzana", "pera", "miel",
                  "leche", "yogur", "trigo", "centeno", "legumbre",
                  "garbanzo", "lenteja", "alubia", "brócoli", "coliflor",
                  "champiñón", "aguacate"]
]
 
// MARK: - Enum PreferenceWarning
 
enum PreferenceWarning: Identifiable {
    case allergen([String])      // Rojo   → alérgeno, no debería aparecer en el menú
    case intolerance([String])   // Naranja → intolerancia, adaptar la receta
    case disliked([String])      // Gris   → no gusta, aviso suave
 
    var id: String { message }
 
    var color: Color {
        switch self {
        case .allergen:    return .red
        case .intolerance: return .orange
        case .disliked:    return .secondary
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
 
func preferenceWarnings(for recipe: Recipe, preferences: UserPreferences?) -> [PreferenceWarning] {
    guard let prefs = preferences else { return [] }
 
    let ingredientNames = recipe.ingredients.map { $0.name.lowercased() }
    var result: [PreferenceWarning] = []
 
    // 1. ALERGIAS — búsqueda directa de la palabra en el nombre del ingrediente
    //  (las alergias también usan el diccionario en MenuGenerator para filtrarlas antes de generar, pero si por algún motivo llegan al menú, se avisa aquí)
    let allergenMatches = prefs.allergies.filter { allergen in
        let key = allergen.lowercased()
        // Primero intenta con el diccionario de intolerancias (cubre ingredientes relacionados)
        if let related = intoleranceIngredients[key] {
            return ingredientNames.contains { name in
                related.contains { name.contains($0) }
            }
        }
        // Si no está en el diccionario, búsqueda directa
        return ingredientNames.contains { $0.contains(key) }
    }
    if !allergenMatches.isEmpty {
        result.append(.allergen(allergenMatches))
    }
 
    // 2. INTOLERANCIAS — usa el diccionario para detectar ingredientes relacionados
    let intoleranceMatches = prefs.intolerances.filter { intolerance in
        let key = intolerance.lowercased()
        if let related = intoleranceIngredients[key] {
            // Comprueba si algún ingrediente de la receta está en la lista de relacionados
            return ingredientNames.contains { name in
                related.contains { name.contains($0) }
            }
        }
        // Si la intolerancia no está en el diccionario, búsqueda directa
        return ingredientNames.contains { $0.contains(key) }
    }
    if !intoleranceMatches.isEmpty {
        result.append(.intolerance(intoleranceMatches))
    }
 
    // 3. PREFERENCIAS (no me gusta) — búsqueda directa
    let dislikeMatches = prefs.dislikes.filter { dislike in
        ingredientNames.contains { $0.contains(dislike.lowercased()) }
    }
    if !dislikeMatches.isEmpty {
        result.append(.disliked(dislikeMatches))
    }
 
    return result
}
 
