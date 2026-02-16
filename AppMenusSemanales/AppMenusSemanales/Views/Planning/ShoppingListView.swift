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
    
    // Aquí guardaremos los nombres de lo que ya has comprado
    @State private var checkedItems: Set<String> = []
    
    // 1. Calculamos la lista agrupada (igual que antes)
    var shoppingList: [IngredientGroup] {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)
        
        let menus = allMenus.filter {
            calendar.component(.weekOfYear, from: $0.date) == weekOfYear
        }
        
        var totals: [String: (Double, String)] = [:]
        
        for menu in menus {
            for ing in menu.lunch.ingredients { addIngredient(to: &totals, ingredient: ing) }
            for ing in menu.dinner.ingredients { addIngredient(to: &totals, ingredient: ing) }
        }
        
        return totals.map { key, value in
            IngredientGroup(name: key, totalQuantity: value.0, unit: value.1)
        }.sorted { $0.name < $1.name }
    }
    
    func addIngredient(to totals: inout [String: (Double, String)], ingredient: Ingredient) {
        let key = ingredient.name.lowercased().capitalized
        if let existing = totals[key], existing.1 == ingredient.unit {
            totals[key] = (existing.0 + ingredient.quantity, existing.1)
        } else if let existing = totals[key] {
            let newKey = "\(key) (\(ingredient.unit))"
            totals[newKey] = (ingredient.quantity, ingredient.unit)
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
                            // Fila interactiva
                            Button(action: { toggleItem(item.name) }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.body)
                                            .strikethrough(isChecked(item.name)) // Tachado si está comprado
                                            .foregroundStyle(isChecked(item.name) ? .gray : .primary)
                                        
                                        Text("\(item.totalQuantity.formatted()) \(item.unit)")
                                            .font(.caption)
                                            .foregroundStyle(.blue)
                                    }
                                    
                                    Spacer()
                                    
                                    // EL CÍRCULO A LA DERECHA (Como pediste)
                                    Image(systemName: isChecked(item.name) ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundStyle(isChecked(item.name) ? .green : .gray)
                                }
                                .contentShape(Rectangle()) // Hace que toda la fila sea pulsable
                            }
                            .buttonStyle(.plain) // Elimina el efecto de botón azul feo
                        }
                    }
                }
            }
            .navigationTitle("Lista de Compra")
            .toolbar {
                // Botón para desmarcar todo (útil para nueva semana)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Limpiar") {
                        clearChecks()
                    }
                    .disabled(checkedItems.isEmpty)
                }
            }
            .onAppear {
                loadChecks() // Cargar memoria al abrir
            }
        }
    }
    
    // MARK: - Lógica de "Checks" (Persistencia)
    
    // Comprobar si está marcado
    func isChecked(_ name: String) -> Bool {
        return checkedItems.contains(name)
    }
    
    // Marcar/Desmarcar y guardar
    func toggleItem(_ name: String) {
        if checkedItems.contains(name) {
            checkedItems.remove(name)
        } else {
            checkedItems.insert(name)
        }
        saveChecks()
    }
    
    // Guardar en UserDefaults (Memoria del móvil)
    func saveChecks() {
        let array = Array(checkedItems)
        UserDefaults.standard.set(array, forKey: "savedShoppingChecks")
    }
    
    // Cargar de la memoria
    func loadChecks() {
        if let saved = UserDefaults.standard.array(forKey: "savedShoppingChecks") as? [String] {
            checkedItems = Set(saved)
        }
    }
    
    func clearChecks() {
        checkedItems.removeAll()
        saveChecks()
    }
}

struct IngredientGroup: Identifiable {
    let id = UUID()
    let name: String
    let totalQuantity: Double
    let unit: String
}
