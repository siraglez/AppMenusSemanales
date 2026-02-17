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
    
    // Guardar lo comprado
    @State private var checkedItems: Set<String> = []
    
    // Estado para saber si la lista de completados está abierta o cerrada
    @State private var isCompletedExpanded: Bool = false
    
    // MARK: LÓGICA DE DATOS
    
    // 1. Calcular la lista TOTAL de ingredientes necesarios
    var fullShoppingList: [IngredientGroup] {
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
    
    // 2. Filtrar: Lo que falta por comprar
    var pendingItems: [IngredientGroup] {
        fullShoppingList.filter { !isChecked($0.name) }
    }
    
    // 3. Filtrar: Lo que ya está comprado
    var completedItems: [IngredientGroup] {
        fullShoppingList.filter { isChecked($0.name) }
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
    
    // MARK: VISTA
    
    var body: some View {
        NavigationStack {
            List {
                if fullShoppingList.isEmpty {
                    ContentUnavailableView("Lista vacía", systemImage: "cart", description: Text("Planifica tu semana para ver la lista de la compra."))
                } else {
                    
                    // SECCIÓN 1: PENDIENTES (Lo importante)
                    if !pendingItems.isEmpty {
                        Section(header: Text("Pendiente (\(pendingItems.count))")) {
                            ForEach(pendingItems) { item in
                                ShoppingRow(item: item, isChecked: false) {
                                    toggleItem(item.name)
                                }
                            }
                        }
                    } else if !completedItems.isEmpty {
                        // Mensaje motivador si has comprado todo
                        Section {
                            HStack {
                                Spacer()
                                Label("¡Compra completada!", systemImage: "checkmark.seal.fill")
                                    .font(.headline)
                                    .foregroundStyle(.green)
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    
                    // SECCIÓN 2: COMPLETADOS (Desplegable)
                    if !completedItems.isEmpty {
                        Section {
                            DisclosureGroup(
                                isExpanded: $isCompletedExpanded,
                                content: {
                                    ForEach(completedItems) { item in
                                        ShoppingRow(item: item, isChecked: true) {
                                            toggleItem(item.name)
                                        }
                                    }
                                },
                                label: {
                                    HStack {
                                        Text("Completado (\(completedItems.count))")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Lista de Compra")
            .toolbar {
                if !checkedItems.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Desmarcar todo") {
                            withAnimation {
                                clearChecks()
                            }
                        }
                        .font(.caption)
                    }
                }
            }
            .onAppear {
                loadChecks()
            }
        }
    }
    
    // MARK: FUNCIONES DE ESTADO
    
    func isChecked(_ name: String) -> Bool {
        return checkedItems.contains(name)
    }
    
    func toggleItem(_ name: String) {
        // Usar withAnimation para que el cambio de sección sea suave
        withAnimation(.snappy) {
            if checkedItems.contains(name) {
                checkedItems.remove(name)
            } else {
                checkedItems.insert(name)
            }
        }
        saveChecks()
    }
    
    func saveChecks() {
        let array = Array(checkedItems)
        UserDefaults.standard.set(array, forKey: "savedShoppingChecks")
    }
    
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

// Subvista para la fila (para no repetir código y dejarlo limpio)
struct ShoppingRow: View {
    let item: IngredientGroup
    let isChecked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Círculo a la derecha
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.body)
                        .strikethrough(isChecked) // Tachado si está completado
                        .foregroundStyle(isChecked ? .gray : .primary)
                    
                    if !isChecked {
                        Text("\(item.totalQuantity.formatted()) \(item.unit)")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                
                Spacer()
                
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isChecked ? .green : .gray)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct IngredientGroup: Identifiable {
    let id = UUID()
    let name: String
    let totalQuantity: Double
    let unit: String
}
