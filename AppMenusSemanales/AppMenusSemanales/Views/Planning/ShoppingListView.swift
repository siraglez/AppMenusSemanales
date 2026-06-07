//
//  ShoppingListView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño
//

// Vista para la lista de la compra

import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Environment(\.modelContext) var context
    
    // Datos del Menú
    @Query var allMenus: [WeeklyMenu]
    @State private var selectedDate = Date()
    
    // Datos Manuales (NUEVO)
    @Query var extraItems: [ExtraItem]
    
    // Estado de la interfaz
    @State private var checkedItems: Set<String> = []
    @State private var isCompletedExpanded: Bool = false
    @State private var showAddSheet: Bool = false // Para mostrar el formulario
    
    // MARK: CÁLCULO INTELIGENTE DE LA LISTA
    
    var fullShoppingList: [IngredientGroup] {
        var totals: [String: (Double, String, Bool)] = [:] // Bool indica si es borrable (manual)
        
        // 1. Sumar ingredientes del MENÚ (Automático)
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)
        let menus = allMenus.filter { calendar.component(.weekOfYear, from: $0.date) == weekOfYear }
        
        for menu in menus {
            // Solo sumamos los ingredientes si la receta sigue existiendo (no es nil)
            if let lunch = menu.lunch {
                for ing in lunch.ingredients {
                    addIngredient(to: &totals, name: ing.name, qty: ing.quantity, unit: ing.unit, isManual: false)
                }
            }
            if let dinner = menu.dinner {
                for ing in dinner.ingredients {
                    addIngredient(to: &totals, name: ing.name, qty: ing.quantity, unit: ing.unit, isManual: false)
                }
            }
        }
        
        // 2. Sumar ítems MANUALES (Extra)
        for item in extraItems {
            addIngredient(to: &totals, name: item.name, qty: item.quantity, unit: item.unit, isManual: true)
        }
        
        // 3. Convertir a lista final
        return totals.map { key, value in
            IngredientGroup(name: key, totalQuantity: value.0, unit: value.1, isManual: value.2)
        }.sorted { $0.name < $1.name }
    }
    
    var pendingItems: [IngredientGroup] { fullShoppingList.filter { !isChecked($0.name) } }
    var completedItems: [IngredientGroup] { fullShoppingList.filter { isChecked($0.name) } }
    
    // Función auxiliar para sumar cantidades
    func addIngredient(to totals: inout [String: (Double, String, Bool)], name: String, qty: Double, unit: String, isManual: Bool) {
        let key = name.lowercased().capitalized
        
        if let existing = totals[key] {
            // Si la unidad coincide, sumamos. Si uno es manual, el total se marca como "contiene manual"
            if existing.1 == unit {
                totals[key] = (existing.0 + qty, existing.1, existing.2 || isManual)
            } else {
                let newKey = "\(key) (\(unit))"
                totals[newKey] = (qty, unit, isManual)
            }
        } else {
            totals[key] = (qty, unit, isManual)
        }
    }
    
    // MARK: VISTA
    
    var body: some View {
        NavigationStack {
            List {
                if fullShoppingList.isEmpty {
                    ContentUnavailableView("Lista vacía", systemImage: "cart", description: Text("Añade productos manualmente o genera un menú."))
                } else {
                    // SECCIÓN PENDIENTES
                    if !pendingItems.isEmpty {
                        Section(header: Text("Pendiente (\(pendingItems.count))")) {
                            ForEach(pendingItems) { item in
                                ShoppingRow(item: item, isChecked: false) { toggleItem(item.name) }
                                // Solo permitimos borrar si es manual (Swipe to delete)
                                    .swipeActions {
                                        if item.isManual {
                                            Button("Borrar", role: .destructive) { deleteManualItem(name: item.name) }
                                        }
                                    }
                            }
                        }
                    } else if !completedItems.isEmpty {
                        Section { Text("¡Todo comprado! 🎉").frame(maxWidth: .infinity, alignment: .center).foregroundStyle(.green) }
                    }
                    
                    // SECCIÓN COMPLETADOS
                    if !completedItems.isEmpty {
                        Section {
                            DisclosureGroup(
                                isExpanded: $isCompletedExpanded,
                                content: {
                                    ForEach(completedItems) { item in
                                        ShoppingRow(item: item, isChecked: true) { toggleItem(item.name) }
                                            .swipeActions {
                                                if item.isManual {
                                                    Button("Borrar", role: .destructive) { deleteManualItem(name: item.name) }
                                                }
                                            }
                                    }
                                },
                                label: { Text("Completado (\(completedItems.count))").foregroundStyle(.secondary) }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Lista de Compra")
            .toolbar {
                // BOTÓN DE AÑADIR (+)
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddExtraItemView() // El formulario para añadir
                    .presentationDetents([.medium])
            }
            .onAppear { loadChecks() }
        }
    }
    
    // MARK: LÓGICA DE BORRADO MANUAL
    func deleteManualItem(name: String) {
        // Buscamos items manuales con ese nombre y los borramos de la BD
        let itemsToDelete = extraItems.filter { $0.name.lowercased().capitalized == name }
        for item in itemsToDelete {
            context.delete(item)
        }
        // Si estaba marcado, lo quitamos de la memoria también
        if checkedItems.contains(name) {
            checkedItems.remove(name)
            saveChecks()
        }
    }
    
    // MARK: LÓGICA DE CHECKS
    func isChecked(_ name: String) -> Bool { checkedItems.contains(name) }
    
    func toggleItem(_ name: String) {
        withAnimation(.snappy) {
            if checkedItems.contains(name) { checkedItems.remove(name) } else { checkedItems.insert(name) }
        }
        saveChecks()
    }
    
    func saveChecks() { UserDefaults.standard.set(Array(checkedItems), forKey: "savedShoppingChecks") }
    func loadChecks() { if let saved = UserDefaults.standard.array(forKey: "savedShoppingChecks") as? [String] { checkedItems = Set(saved) } }
}

// --- SUBVISTA: FILA DE LA LISTA ---
struct ShoppingRow: View {
    let item: IngredientGroup
    let isChecked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.body)
                        .strikethrough(isChecked)
                        .foregroundStyle(isChecked ? .gray : .primary)
                    if !isChecked {
                        Text("\(item.totalQuantity.formatted()) \(item.unit)" + (item.isManual ? " (Extra)" : ""))
                            .font(.caption)
                            .foregroundStyle(item.isManual ? .purple : .blue)
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

// --- SUBVISTA: FORMULARIO PARA AÑADIR ---
struct AddExtraItemView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @State private var name = ""
    @State private var quantity = ""
    @State private var unit = "ud"
    let units = ["ud", "kg", "g", "L", "ml", "paquete", "bote"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Nuevo Producto") {
                    TextField("Nombre (ej: Papel Higiénico)", text: $name)
                    HStack {
                        TextField("Cantidad", text: $quantity)
                            .keyboardType(.decimalPad)
                        Picker("Unidad", selection: $unit) {
                            ForEach(units, id: \.self) { Text($0) }
                        }
                    }
                }
            }
            .navigationTitle("Añadir a la lista")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Añadir") {
                        let qty = Double(quantity.replacingOccurrences(of: ",", with: ".")) ?? 1.0
                        let newItem = ExtraItem(name: name, quantity: qty, unit: unit)
                        context.insert(newItem)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// Estructura auxiliar mejorada
struct IngredientGroup: Identifiable {
    let id = UUID()
    let name: String
    let totalQuantity: Double
    let unit: String
    let isManual: Bool // Para saber si podemos borrarlo o no
}
