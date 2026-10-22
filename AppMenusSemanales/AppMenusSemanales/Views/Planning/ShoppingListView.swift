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
    
    @Query var allMenus: [WeeklyMenu]
    @Binding var selectedDate: Date
    
    @Query var extraItems: [ExtraItem]
    @Query var familyMembers: [FamilyMember]
    
    // Espacio activo (compartido con el Planificador)
    @AppStorage("currentSpace") var currentSpaceRaw: String = MenuSpace.familiar.rawValue
    var currentSpace: MenuSpace { MenuSpace(rawValue: currentSpaceRaw) ?? .familiar }
    
    @State private var checkedItems: Set<String> = []
    @State private var isCompletedExpanded: Bool = false
    @State private var showAddSheet: Bool = false
    
    // Comensales. En el espacio personal solo tú; en el familiar, tú + los que están en casa
    var dinersCount: Int {
        currentSpace == .familiar ? 1 + familyMembers.filter { $0.isAtHome }.count : 1
    }
    
    // MARK: CÁLCULO DE LA LISTA
    var fullShoppingList: [IngredientGroup] {
        var totals: [String: (Double, String, Bool)] = [:]
        
        // 1. Ingredientes del MENÚ de la semana seleccionada y del espacio activo
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)
        let year = calendar.component(.yearForWeekOfYear, from: selectedDate)
        let menus = allMenus.filter {
            calendar.component(.weekOfYear, from: $0.date) == weekOfYear &&
            calendar.component(.yearForWeekOfYear, from: $0.date) == year && $0.space == currentSpace
        }
        
        for menu in menus {
            if let lunch = menu.lunch {
                let factor = servingsFactor(for: lunch)
                for ing in lunch.ingredients ?? [] {
                    addIngredient(to: &totals, name: ing.name,
                                  qty: ing.quantity * factor, unit: ing.unit, isManual: false)
                }
            }
            if let dinner = menu.dinner {
                let factor = servingsFactor(for:dinner)
                for ing in dinner.ingredients ?? [] {
                    addIngredient(to: &totals, name: ing.name,
                                  qty: ing.quantity * factor, unit: ing.unit, isManual: false)
                }
            }
        }
        
        // 2. Productos MANUALES del espacio activo (no se escalan)
        for item in extraItems where item.space == currentSpace {
            addIngredient(to: &totals, name: item.name, qty: item.quantity, unit: item.unit, isManual: true)
        }
        
        return totals.map { key, value in
            IngredientGroup(name: key, totalQuantity: value.0, unit: value.1, isManual: value.2)
        }.sorted { $0.name < $1.name }
    }
    
    func servingsFactor(for recipe: Recipe) -> Double {
        let base = max(recipe.baseServings, 1)
        return Double(dinersCount) / Double(base)
    }
    
    var pendingItems: [IngredientGroup] { fullShoppingList.filter { !isChecked($0.name) } }
    var completedItems: [IngredientGroup] { fullShoppingList.filter { isChecked($0.name) } }
    
    func addIngredient(to totals: inout [String: (Double, String, Bool)], name: String, qty: Double, unit: String, isManual: Bool) {
        let key = name.lowercased().capitalized
        if let existing = totals[key] {
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
                // Semana (compartida con el Planificador)
                Section {
                    HStack {
                        Button { moveWeek(by: -1) } label: {
                            Image(systemName: "chevron.left.circle.fill").font(.title3)
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.gray)
                        .accessibilityLabel("Semana anterior")
                        
                        Spacer()
                        VStack {
                            Text(weekLabel).font(.subheadline).fontWeight(.medium)
                            Text(dateRangeLabel).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        
                        Button { moveWeek(by: 1) } label: {
                            Image(systemName: "chevron.right.circle.fill").font(.title3)
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.blue)
                        .accessibilityLabel("Semana siguiente")
                    }
                }
                
                // Comensales (automático)
                Section {
                    HStack {
                        Label("Comensales", systemImage: "person.2.fill")
                        Spacer()
                        Text("\(dinersCount)")
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                } footer: {
                    Text(currentSpace == .familiar
                    ? "Espacio familiar: tú + los miembros marcados como 'en casa'. Las cantidades del menú se ajustan a este número."
                         : "Espacio personal: las cantidades se calculan solo para ti.")
                }
                
                if fullShoppingList.isEmpty {
                    Section {
                        Text("Añade productos manualmente o genera un menú para esta semana.")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    if !pendingItems.isEmpty {
                        Section(header: Text("Pendiente (\(pendingItems.count))")) {
                            ForEach(pendingItems) { item in
                                ShoppingRow(item: item, isChecked: false) { toggleItem(item.name) }
                                    .swipeActions {
                                        if item.isManual {
                                            Button("Borrar", role: .destructive) { deleteManualItem(name: item.name) }
                                        }
                                    }
                            }
                        }
                    } else if !completedItems.isEmpty {
                        Section { Text("¡Todo comprado! 🎉").frame(maxWidth: .infinity, alignment: .center).foregroundStyle(.green)
                        }
                    }
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
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddSheet = true}) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Añadir producto")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddExtraItemView(space: currentSpace).presentationDetents([.medium])
            }
            .onAppear { loadChecks() }
        }
    }
    
    // MARK: NAVEGACIÓN DE SEMANA
    func moveWeek(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    var weekLabel: String {
        Calendar.current.isDateInThisWeek(selectedDate) ? "Esta Semana" : "Semana \(Calendar.current.component(.weekOfYear, from: selectedDate))"
    }
    
    var dateRangeLabel: String {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) ?? selectedDate
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? selectedDate
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    // MARK: BORRADO MANUAL
    func deleteManualItem(name: String) {
        let itemsToDelete = extraItems.filter {
            $0.name.lowercased().capitalized == name && $0.space == currentSpace
        }
        for item in itemsToDelete {
            context.delete(item)
        }
        if checkedItems.contains(name) {
            checkedItems.remove(name)
            saveChecks()
        }
    }
    
    // MARK: CHECKS
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

// --- SUBVISTA: FORMULARIO PARA AÑADIR
struct AddExtraItemView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    // Espacio al que se añadirá el producto
    let space: MenuSpace
    
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
                        newItem.space = space // Marcar con el espacio activo
                        context.insert(newItem)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct IngredientGroup: Identifiable {
    let id = UUID()
    let name: String
    let totalQuantity: Double
    let unit: String
    let isManual: Bool
}
