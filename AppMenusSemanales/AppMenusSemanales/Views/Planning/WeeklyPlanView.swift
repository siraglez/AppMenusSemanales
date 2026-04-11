//
//  WeeklyPlanView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
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
    
    @Binding var selectedTab: Int
    
    @State private var selectedDate = Date()
    @State private var showRegenerateAlert = false
    @State private var selectedSeason: Season = .all
    @State private var showNotEnoughAlert = false
    
    // Para ordenar los días correctamente siempre
    let daysOrder = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    
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
                // Menú de opciones (Tres puntitos)
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
            // Alerta para confirmar regeneración
            .alert("¿Crear nuevo menú?", isPresented: $showRegenerateAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Sí, crear", action: { generateMenu() })
            } message: {
                Text("Esto borrará el menú actual de esta semana y creará uno nuevo.")
            }
            .alert("Pocas recetas disponibles", isPresented: $showNotEnoughAlert) {
                Button("Ir a añadir recetas") {
                    selectedTab = 1
                }
                Button("Generar igualmente") {
                    generateMenu(ignoreLastWeekRule: true)   
                }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Necesitas al menos 14 recetas distintas (sin contar las de la semana anterior) para evitar repeticiones. Puedes añadir más recetas o generar el menú ignorando esa restricción.")
            }
        }
    }
    
    // MARK: - Lógica de Filtrado y Orden
    
    // Filtrar los menús para mostrar SOLO los de la semana seleccionada
    var currentWeekMenu: [WeeklyMenu] {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)
        let year = calendar.component(.yearForWeekOfYear, from: selectedDate)
        
        let menus = allMenus.filter { menu in
            let menuWeek = calendar.component(.weekOfYear, from: menu.date)
            let menuYear = calendar.component(.yearForWeekOfYear, from: menu.date)
            return menuWeek == weekOfYear && menuYear == year
        }
        
        // Ordenar de Lunes a Domingo
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
                Text(weekLabel)
                    .font(.headline)
                Text(dateRangeLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
                    // Fila comida
                    NavigationLink(destination: RecipeDetailView(recipe: dailyPlan.lunch)) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundStyle(.orange)
                                .font(.title3)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading) {
                                Text("Comida")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(dailyPlan.lunch.name)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    
                    // Fila cena
                    NavigationLink(destination: RecipeDetailView(recipe: dailyPlan.dinner)) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.purple)
                                .font(.title3)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading) {
                                Text("Cena")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(dailyPlan.dinner.name)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                } header: {
                    // Cabecera del día
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
                
                Button("Generar Menú Ahora") {
                    generateMenu()
                }
                .buttonStyle(.borderedProminent)
                .disabled(allRecipes.count < 2)
            }
        }
    }
    
    // MARK: - Funciones Auxiliares
    
    // IDs de las recetas usadas la semana anterior (para la regla de 15 días)
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
            ids.insert(menu.lunch.id)
            ids.insert(menu.dinner.id)
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
        // Calcula el rango de fechas para mostrar (ej: 12 Feb - 18 Feb)
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
    
    func generateMenu(ignoreLastWeekRule: Bool = false) {
        let excluded = ignoreLastWeekRule ? [] : lastWeekExcludedIDs
        
        // Comprobar si hay suficientes recetas ANTES de generar
        // Si no las hay y el usuario aún no ha confirmado, mostrar el aviso
        let candidates = allRecipes.filter { !excluded.contains($0.id) }
        if candidates.count < 14 && !ignoreLastWeekRule {
            showNotEnoughAlert = true
            return  
        }
        
        // Si el usuario pulsó "Generar igualmente" o hay suficientes recetas, generamos directamente
        let result = MenuGenerator.generateWeekMenu(
            recipes: allRecipes,
            forWeekOf: selectedDate,
            season: selectedSeason,
            excludedRecipeIDs: excluded
        )
        switch result {
        case .success(let newMenu):
            deleteCurrentWeek()
            for dayPlan in newMenu { context.insert(dayPlan) }
        case .failure:
            // Solo llegaría aquí si no hay ni una sola receta en la app
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
