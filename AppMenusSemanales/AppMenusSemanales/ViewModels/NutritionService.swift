//
//  NutritionService.swift
//  AppMenusSemanales
//
//  Created by Sira González-Madroño 
//
// Llama a la API de USDA para calcular el valor nutricional de una receta

import Foundation
import Translation

// Datos nutricionales básicos de una receta completa
struct NutritionInfo {
    var calories: Double = 0
    var proteins: Double = 0
    var carbs: Double = 0
    var fats: Double = 0
}

class NutritionService {
    
    private static let apiKey = "zXr5QO3c0pMJmlanghvKyBxeJ330IJeGoibzkdeA"
    
    private static var translationCache: [String: String] = [:]
    
    // MARK: - Diccionario de traducción Español -> Inglés (FALLBACK)
    private static let translations: [String: String] = [
            // Carnes y aves
            "pollo": "chicken", "pechuga de pollo": "chicken breast", "muslo de pollo": "chicken thigh",
            "ternera": "beef", "carne picada": "ground beef", "cerdo": "pork", "lomo": "pork loin",
            "jamón": "ham", "bacon": "bacon", "chorizo": "chorizo", "salchichón": "salami",
            "pavo": "turkey", "cordero": "lamb", "conejo": "rabbit",
            // Pescados y mariscos
            "salmón": "salmon", "atún": "tuna", "merluza": "hake", "bacalao": "cod",
            "sardina": "sardine", "gambas": "shrimp", "mejillones": "mussels", "calamar": "squid",
            "pulpo": "octopus", "anchoas": "anchovies", "trucha": "trout", "dorada": "sea bream",
            "boquerones": "anchovies",
            // Verduras y hortalizas
            "tomate": "tomato", "cebolla": "onion", "ajo": "garlic", "pimiento": "bell pepper",
            "zanahoria": "carrot", "patata": "potato", "papa": "potato", "lechuga": "lettuce",
            "espinaca": "spinach", "brócoli": "broccoli", "coliflor": "cauliflower",
            "berenjena": "eggplant", "calabacín": "zucchini", "pepino": "cucumber",
            "puerro": "leek", "apio": "celery", "espárrago": "asparagus", "alcachofa": "artichoke",
            "judía verde": "green bean", "guisante": "pea", "maíz": "corn", "remolacha": "beet",
            "champiñón": "mushroom", "seta": "mushroom", "cebolleta": "scallion",
            // Frutas
            "manzana": "apple", "naranja": "orange", "limón": "lemon", "plátano": "banana",
            "fresa": "strawberry", "uva": "grape", "melocotón": "peach", "pera": "pear",
            "sandía": "watermelon", "melón": "melon", "piña": "pineapple", "mango": "mango",
            // Legumbres
            "lenteja": "lentil", "garbanzo": "chickpea", "alubia": "white bean",
            "judía": "kidney bean", "soja": "soy", "habas": "fava beans",
            // Cereales y pasta
            "arroz": "rice", "pasta": "pasta", "macarrón": "macaroni", "espagueti": "spaghetti",
            "pan": "bread", "pan de molde": "white bread", "harina": "flour",
            "avena": "oats", "quinoa": "quinoa", "cuscús": "couscous",
            // Lácteos y huevos
            "leche": "milk", "queso": "cheese", "queso manchego": "manchego cheese",
            "yogur": "yogurt", "mantequilla": "butter", "nata": "heavy cream",
            "huevo": "egg", "clara de huevo": "egg white", "yema de huevo": "egg yolk",
            // Aceites y grasas
            "aceite de oliva": "olive oil", "aceite": "vegetable oil",
            // Condimentos y otros
            "sal": "salt", "azúcar": "sugar", "pimienta": "black pepper",
            "tomate frito": "tomato sauce", "caldo de pollo": "chicken broth",
            "caldo de verduras": "vegetable broth", "vinagre": "vinegar",
            "mayonesa": "mayonnaise", "mostaza": "mustard", "ketchup": "ketchup",
            "salsa de soja": "soy sauce", "miel": "honey"
    ]
    
    // MARK: - Detección automática de categoría
    static func detectCategory(from ingredients: [Ingredient]) -> RecipeCategory {
        let names = ingredients.map { $0.name.lowercased() }

        func matches(_ keywords: [String]) -> Int {
            keywords.filter { kw in names.contains { $0.contains(kw) } }.count
        }

        let scores: [(RecipeCategory, Int)] = [
            (.meat,      matches(["pollo", "ternera", "cerdo", "lomo", "pavo", "cordero",
                                  "conejo", "carne", "jamón", "bacon", "chorizo", "pechuga",
                                  "muslo", "filete", "costilla", "hamburguesa", "salchicha"])),
            (.fish,      matches(["salmón", "atún", "merluza", "bacalao", "sardina", "gambas",
                                  "mejillones", "calamar", "pulpo", "anchoas", "boquerones",
                                  "trucha", "dorada", "pescado", "marisco", "langostino", "sepia"])),
            (.legume,    matches(["lenteja", "garbanzo", "alubia", "judía", "soja", "habas", "legumbre"])),
            (.vegetable, matches(["espinaca", "brócoli", "coliflor", "berenjena", "calabacín",
                                  "pimiento", "zanahoria", "lechuga", "pepino", "puerro",
                                  "apio", "espárrago", "alcachofa", "verdura", "ensalada", "remolacha"])),
            (.eggs,      matches(["huevo", "tortilla", "clara", "yema"])),
            (.pastaRice, matches(["pasta", "arroz", "macarrón", "espagueti", "fideos", "lasaña", "cuscús", "quinoa", "risotto"]))
        ]

        // Si hay pasta o arroz, eso define la receta
        if let pastaScore = scores.first(where: { $0.0 == .pastaRice }), pastaScore.1 > 0 {
            return .pastaRice
        }
        // Si hay legy¡umbres, eso define la receta
        if let legumeScore = scores.first(where: { $0.0 == .legume }), legumeScore.1 > 0 {
            return .legume
        }
        // Para el resto, la categoría con más coincidencias gana
        if let best = scores.max(by: { $0.1 < $1.1 }), best.1 > 0 {
            return best.0
        }
        return .other
    }
    
    // MARK: - Función principal
    static func calculateNutrition(
        for ingredients: [Ingredient],
        translationSession: TranslationSession? = nil
    ) async -> NutritionInfo {
        var total = NutritionInfo()
        
        for ingredient in ingredients {
            let englishName: String
            if let session = translationSession {
                englishName = await translateWithApple(ingredient.name, session: session)
            } else {
                englishName = translateWithDictionary(ingredient.name)
            }
            
            // Llamada a la API por cada ingrediente
            if let perHundredGrams = await fetchNutrients(for: englishName) {
                let scale = scaleFactor(quantity: ingredient.quantity, unit: ingredient.unit)
                total.calories += perHundredGrams.calories * scale
                total.proteins += perHundredGrams.proteins * scale
                total.carbs += perHundredGrams.carbs * scale
                total.fats += perHundredGrams.fats * scale
            }
        }
        
        return total
    }
    
    // MARK: - Traducción con Apple Translation
    private static func translateWithApple(_ text: String, session: TranslationSession) async -> String {
        let key = text.lowercased().trimmingCharacters(in: .whitespaces)
        
        if let cached = translationCache[key] { return cached }
        
        do {
            let response = try await session.translate(text)
            let result = response.targetText
            translationCache[key] = result
            return result
        } catch {
            return translateWithDictionary(text)
        }
    }
    
    // MARK: - Traducción con diccionario
    private static func translateWithDictionary(_ name: String) -> String {
        let key = name.lowercased().trimmingCharacters(in: .whitespaces)
        return translations[key] ?? name
    }
    
    // MARK: - Llamada a la API de USDA
    private static func fetchNutrients(for foodName: String) async -> NutritionInfo? {
        let encoded = foodName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? foodName
        let urlString = "https://api.nal.usda.gov/fdc/v1/foods/search?query=\(encoded)&pageSize=1&api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from:url)
            let decoded = try JSONDecoder().decode(USDAResponse.self, from: data)
            guard let food = decoded.foods.first else { return nil }
            
            // Buscar los 4 nutrientes por su ID de USDA
            var info = NutritionInfo()
            for nutrient in food.foodNutrients {
                switch nutrient.nutrientId {
                case 1008: info.calories = nutrient.value ?? 0 // Energía (kcal)
                case 1003: info.proteins = nutrient.value ?? 0 // Proteínas (g)
                case 1005: info.carbs = nutrient.value ?? 0 // Carbohidratos (g)
                case 1004: info.fats = nutrient.value ?? 0 // Grasas (g)
                default: break
                }
            }
            return info
        } catch {
            return nil // Si falla, ignoramos ese ingrediente
        }
    }
    
    // MARK: - Factor de escala (la API devuelve nutrientes por cada 100g)
    private static func scaleFactor(quantity: Double, unit: String) -> Double {
        switch unit.lowercased() {
        case "g": return quantity / 100
        case "kg": return quantity * 10
        case "ml": return quantity / 100 // Asumiendo densidad aproximada de 1g/ml
        case "l": return quantity * 10
        case "cucharada": return quantity * 0.15 // Asumiendo aproximadamente 15g por cucharada
        case "pizca": return quantity * 0.01 // Asumiendo aproximadamente 1g por pizca
        case "ud": return quantity * 1.0 // Asumiengo aproximadamente 100g por unidad
        default: return quantity / 100
        }
    }
}

// MARK: - Modelos de la respuesta JSON de USDA

private struct USDAResponse: Decodable {
    let foods: [USDAFood]
}

private struct USDAFood: Decodable {
    let foodNutrients: [USDANutrient]
}

private struct USDANutrient: Decodable {
    let nutrientId: Int
    let value: Double?
}
