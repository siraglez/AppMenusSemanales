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
    // 1. Es necesario acceso a la base de datos para guardar/borrar
    @Environment(\.modelContext) var context
    
    // 2. Trar TODO el histórico de menús
    @Query var allMenus: [WeeklyMenu]
    
    // 3. Traer TODAS las recetas para que el generador pueda elegir
    @Query var allRecipes: [Recipe]
    
    @State private var selectedDate = Date()
    @State private var showRegenerateAlert = false
    @State private var selectedSeason: Season = .all
    
    // Para ordenar los días correctamente siempre
    let daysOrder = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // --- 1. Cabecera de Calendario ---
                weekHeaderControl
                    .padding()
                    .background(Color.(.systemGroupedBackground))
                
                // --- 2. Lista o Mensaje vacío ---
                if currentWeekMenu.isEmpty {
                    emptySateView
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
                        Button(action: { showRegenerteAlet = true }) {
                            Label("Regenerar Menú", systemImage: "arrow.triangle.2.circlepath")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
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
                                        Text("comida")
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
                                Text(dailyPlan.date.formatted(dateTime.day().month()))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .listStyle(.insertGrouped)
            }
            
            var emptyStateView: someView {
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
                    
                    func generateMenu() {
                        // 1. Borramos si había algo esa semana
                        deleteCurrentWeek()
                        
                        // 2. Generamos nuevo menú pasándole la fecha seleccionada
                        let newMenu = MenuGenerator.generateWeekMenu(recipes: allRecipes, forWeekOf: selectedDate, season: selectedSeason)
                        
                        // 3. Guardamos
                        for dayPlan in newMenu {
                            context.insert(dayPlan)
                        }
                    }
                    
                    func deleteCurrentWeek() {
                        for item in currentWeekMenu {
                            context.delete(item)
                        }
                    }
                }

                // Extensión pequeña para ayudar a detectar la semana actual
                extension Calendar {
                    func isDateInThisWeek(_ date: Date) -> Bool {
                        return isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
                    }
                }
