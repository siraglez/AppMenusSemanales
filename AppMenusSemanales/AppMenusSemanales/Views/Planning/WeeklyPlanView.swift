//
//  WeeklyPlanView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño
//
// Pantalla principal del menú semanal

import SwiftUI
import SwiftData

struct WeeklyPlanView: View {
    // 1. Acceso a la base de datos para guardar/borrar
    @Environment(\.modelContext) var context
    
    // 2. Traer TODO el histórico de menús
    @Query var allMenus: [WeeklyMenu]
    
    // 3. Traer TODAS las recetas para que el generador pueda elegir
    @Query var allRecipes: [Recipe]
    
    @Query var userPreferences: [UserPreferences]
    @Query var fixedAssignments: [FixedAssignment]
    
    @Binding var selectedTab: Int
    
    @State private var selectedDate = Date()
    @State private var showRegenerateAlert = false
    @State private var selectedSeason: Season = .all
    @State private var showNotEnoughAlert = false
    @State private var showAvailabilityAlert = false
    
    // Para ordenar los días correctamente siempre
    let daysOrder = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    
    // Acceso conveniente a las preferencias (solo hay un objeto en la BD)
    var preferences: UserPreferences? { userPreferences.first { $0.member == nil } }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // --- 1. Cabecera de Calendario ---
                weekHeaderControl
                    .padding()
                    .background(Color(.systemGroupedBackground))
                
                // --- 2. Lista o Mensaje vacío ---
                if currentWeekMenu.isEmpty {
                    emptyStateView
                } else {
                    menuListView
                }
            }
            .navigationTitle("Plan Semanal")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: deleteCurrentWeek) {
                            Label("Borrar esta semana", systemImage: "trash")
                        }
                        Button(action: { showRegenerateAlert = true }) {
                            Label("Regenerar Menú", systemImage: "arrow.triangle.2.circlepath")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("¿Crear nuevo menú?", isPresented: $showRegenerateAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Sí, crear", action: { generateMenu() })
            } message: {
                Text("Esto borrará el menú actual de esta semana y creará uno nuevo.")
            }
            // Aviso de pocas recetas para no repetir
            .alert("Pocas recetas disponibles", isPresented: $showNotEnoughAlert) {
                Button("Ir a añadir recetas") { selectedTab = 1 }
                Button("Generar igualmente") { generateMenu(ignoreLastWeekRule: true) }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Necesitas al menos 14 recetas distintas (sin contar las de la semana anterior) para evitar repeticiones. Puedes añadir más recetas o generar el menú ignorando esa restricción.")
            }
            // Aviso de disponibilidad entre semana / fin de semana
            .alert("Pocas recetas para la disponibilidad", isPresented: $showAvailabilityAlert) {
                Button("Ir a añadir recetas") { selectedTab = 1 }
                Button("Generar igualmente") { generateMenu(ignoreLastWeekRule: true, ignoreAvailability: true) }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("No hay suficientes recetas marcadas como 'entre semana' o 'fin de semana' para cubrir todos los días respetando esa preferencia. Puedes añadir más recetas, o generar el menú usando recetas de fin de semana entre semana (o viceversa).")
            }
        }
    }
    
    // MARK: - Lógica de Filtrado y Orden
    var currentWeekMenu: [WeeklyMenu] {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)
        let year = calendar.component(.yearForWeekOfYear, from: selectedDate)
        
        let menus = allMenus.filter { menu in
            let menuWeek = calendar.component(.weekOfYear, from: menu.date)
            let menuYear = calendar.component(.yearForWeekOfYear, from: menu.date)
            return menuWeek == weekOfYear && menuYear == year
        }
        
        return menus.sorted { (menu1, menu2) -> Bool in
            guard let index1 = daysOrder.firstIndex(of: menu1.dayName),
                  let index2 = daysOrder.firstIndex(of: menu2.dayName) else {
                return false
            }
            return index1 < index2
        }
    }
    
    // MARK: - Componentes Visuales
    var weekHeaderControl: some View {
        HStack {
            Button(action: { moveWeek(by: -1) }) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.gray)
            }
            Spacer()
            VStack {
                Text(weekLabel).font(.headline)
                Text(dateRangeLabel).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: { moveWeek(by: 1) }) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
        }
    }
    
    var menuListView: some View {
        List {
            ForEach(currentWeekMenu) { dailyPlan in
                Section {
                    // Fila comida: si la receta existe, navegable; si no, hueco vacío
                    if let lunch = dailyPlan.lunch {
                        NavigationLink(destination: RecipeDetailView(recipe: lunch)) {
                            recipeRow(recipe: lunch, mealLabel: "Comida",
                                      icon: "sun.max.fill", iconColor: .orange)
                        }
                    } else {
                        emptySlotRow(mealLabel: "Comida", icon: "sun.max.fill", iconColor: .orange)
                    }
                    
                    // Fila cena
                    if let dinner = dailyPlan.dinner {
                        NavigationLink(destination: RecipeDetailView(recipe: dinner)) {
                            recipeRow(recipe: dinner, mealLabel: "Cena",
                                      icon: "moon.fill", iconColor: .purple)
                        }
                    } else {
                        emptySlotRow(mealLabel: "Cena", icon: "moon.fill", iconColor: .purple)
                    }
                } header: {
                    HStack {
                        Text(dailyPlan.dayName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(dailyPlan.date.formatted(.dateTime.day().month()))
                            .font(.caption)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // Fila de receta con avisos de preferencias debajo del nombre
    @ViewBuilder
    func recipeRow(recipe: Recipe, mealLabel: String, icon: String, iconColor: Color) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title3)
                .frame(width: 30)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mealLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(recipe.name)
                    .fontWeight(.medium)
                
                let warnings = preferenceWarnings(for: recipe, preferences: preferences)
                ForEach(warnings) { warning in
                    Label(warning.message, systemImage: warning.icon)
                        .font(.caption2)
                        .foregroundStyle(warning.color)
                }
            }
        }
    }
    
    // Fila para un hueco vacío (la receta que había aquí fue borrada)
    @ViewBuilder
    func emptySlotRow(mealLabel: String, icon: String, iconColor: Color) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundStyle(iconColor.opacity(0.4))
                .font(.title3)
                .frame(width: 30)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mealLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Sin receta")
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
    }
    
    var emptyStateView: some View {
        ContentUnavailableView {
            Label("Semana libre", systemImage: "calendar")
        } description: {
            Text("No hay menú planificado para esta semana.")
        } actions: {
            VStack {
                Picker("Estación", selection: $selectedSeason) {
                    Text("Todas").tag(Season.all)
                    Text("Verano").tag(Season.summer)
                    Text("Invierno").tag(Season.winter)
                }
                .pickerStyle(.segmented)
                .frame(width: 250)
                .padding(.bottom)
                
                Button("Generar Menú Ahora") { generateMenu() }
                    .buttonStyle(.borderedProminent)
                    .disabled(allRecipes.count < 2)
            }
        }
    }
    
    // MARK: - Funciones Auxiliares
    var lastWeekExcludedIDs: Set<UUID> {
        let calendar = Calendar.current
        guard let lastWeekDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) else { return [] }
        
        let lastWeekOfYear = calendar.component(.weekOfYear, from: lastWeekDate)
        let lastYear       = calendar.component(.yearForWeekOfYear, from: lastWeekDate)
        
        let lastWeekMenus = allMenus.filter {
            calendar.component(.weekOfYear, from: $0.date)        == lastWeekOfYear &&
            calendar.component(.yearForWeekOfYear, from: $0.date) == lastYear
        }
        
        var ids = Set<UUID>()
        for menu in lastWeekMenus {
            if let lunch = menu.lunch   { ids.insert(lunch.id) }
            if let dinner = menu.dinner { ids.insert(dinner.id) }
        }
        return ids
    }
    
    var weekLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInThisWeek(selectedDate) {
            return "Esta Semana"
        } else {
            return "Semana \(calendar.component(.weekOfYear, from: selectedDate))"
        }
    }
    
    var dateRangeLabel: String {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) ?? selectedDate
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? selectedDate
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    func moveWeek(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    func generateMenu(ignoreLastWeekRule: Bool = false, ignoreAvailability: Bool = false) {
        let excluded = ignoreLastWeekRule ? [] : lastWeekExcludedIDs
        
        // Comprobar si hay suficientes recetas ANTES de generar
        let candidates = allRecipes.filter { !excluded.contains($0.id) }
        if candidates.count < 14 && !ignoreLastWeekRule {
            showNotEnoughAlert = true
            return
        }
        
        let result = MenuGenerator.generateWeekMenu(
            recipes: allRecipes,
            forWeekOf: selectedDate,
            season: selectedSeason,
            excludedRecipeIDs: excluded,
            preferences: preferences,
            fixedAssignments: fixedAssignments,
            ignoreAvailability: ignoreAvailability
        )
        switch result {
        case .success(let newMenu):
            deleteCurrentWeek()
            for dayPlan in newMenu { context.insert(dayPlan) }
        case .failure(.notEnoughForAvailability):
            showAvailabilityAlert = true
        case .failure:
            showNotEnoughAlert = true
        }
    }
    
    func deleteCurrentWeek() {
        for item in currentWeekMenu {
            context.delete(item)
        }
    }
}

// MARK: - Extensiones
extension Calendar {
    func isDateInThisWeek(_ date: Date) -> Bool {
        return isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

