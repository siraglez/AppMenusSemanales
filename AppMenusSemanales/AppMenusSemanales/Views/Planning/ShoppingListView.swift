//
//  ShoppingListView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 16/2/26.
//

// Vista para la lista de la compra

import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Query var allMenus: [WeeklyMenu]
    @State private var selectedDate = Date()
    
    // Lógica calculada: Filtra la semana y suma ingredientes
    var shoppingList: [IngredientGroup] {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)
        
        // 1. Obtener menús de esta semana
        let menus = allMenus.filter {
            calendar.component(.weekOfYear, from: $0.date) == weekOfYear
        }
        
        // 2. Acumular ingredientes
        var totals: [String: (Double, String)] = [:] // Clave: Nombre -> Valor: (Cantidad, Unidad)
        
        for menu in menus {
            // Sumar ingredientes de la comida
            for ing in menu.lunch.ingredients {
                addIngredient(to: &totals, ingredient: ing)
            }
            // Sumar ingredientes de la cena
            for ing in menu.dinner.ingredients {
                addIngredient(to: &totals, ingredient: ing)
            }
        }
        
        // 3. Convertir diccionario a Array para la lista
        return totals.map { key, value in
            IngredientGroup(name: key, totalQuantity: value.0, unit: value.1)
        }.sorted { $0.name < $1.name }
    }
    
    // Función auxiliar para sumar
    func addIngredient(to totals: inout [String: (Double, String)], ingredient: Ingredient) {
        // Clave compuesta para diferenciar "Tomate (ud)" de "Tomate (kg)"
        let key = ingredient.name.lowercased().capitalized
        
        if let existing = totals[key] {
            // Si ya existe y la unidad coincide, sumamos
            if existing.1 == ingredient.unit {
                totals[key] = (existing.0 + ingredient.quantity, existing.1)
            } else {
                // Si la unidad es distinta, lo guardamos como otro ítem (simplificación TFG)
                let newKey = "\(key) (\(ingredient.unit))"
                totals[newKey] = (ingredient.quantity, ingredient.unit)
            }
        } else {
            totals[key] = (ingredient.quantity, ingredient.unit)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if shoppingList.isEmpty {
                    ContentUnavailableView("Lista vacía", systemImage: "cart", description: Text("Planifica tu semana para ver la lista de la compra."))
                } else {
                    Section(header: Text("Para la semana actual")) {
                        ForEach(shoppingList) { item in
                            HStack {
                                Image(systemName: "circle") // Checkbox visual
                                    .foregroundStyle(.gray)
                                Text(item.name)
                                    .bold()
                                Spacer()
                                Text("\(item.totalQuantity.formatted()) \(item.unit)")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Lista de Compra")
        }
    }
}

// Estructura auxiliar para mostrar la lista agrupada
struct IngredientGroup: Identifiable {
    let id = UUID()
    let name: String
    let totalQuantity: Double
    let unit: String
}
