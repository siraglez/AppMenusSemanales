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
    
    // 2. Trar el menú actual guardado (si existe)
    @Query var weeklyMenu: [WeeklyMenu]
    
    // 3. Traer TODAS las recetas para que el generador pueda elegir
    @Query var allRecipes: [Recipe]
    
    @State private var selectedSeason: Season = .all
    
    var body: some View {
        NavigationStack {
            VStack {
                if weeklyMenu.isEmpty {
                    // --- VISTA ESTADO VACÍO ---
                    emptyStateView
                } else {
                    // --- VISTA CON MENÚ ---
                    menuListView
                }
            }
            .navigationTitle("Plan Semanal")
            .toolbar {
                if !weeklyMenu.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: deleteMenu) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Subvistas
    
    var emptyStateView: some View {
        ContentUnavailableView {
            Label("Sin Planificación", systemImage: "calendar.badge.exclamationmark")
        } description: {
            Text("No tienes un menú activo para esta semana.")
        } actions: {
            VStack(spacing: 15) {
                // Selector de estación para el algoritmo
                Picker("Estación", selection: $selectedSeason) {
                    Text("Cualquiera").tag(Season.all)
                    Text("Verano").tag(Season.summer)
                    Text("Invierno").tag(Season.winter)
                }
                .pickerStyle(.segmented)
                .frame(width: 250)
                
                Button(action: generateMenu) {
                    Text("Generar Menú Automático")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(allRecipes.count < 2) // Bloquear si no hay recetas suficientes
            }
            .padding()
        }
    }
    
    var menuListView: some View {
        List {
            // Recorremos el menú guardado
            ForEach(weeklyMenu) { dailyPlan in
                Section(header: Text(dailyPlan.day).font(.headline)) {
                    // Fila Comida
                    NavigationLink(destination: RecipeDetailView(recipe:dailyPlan.lunch)) {
                        HStack {
                            Image(systemName: "sin.max.fill")
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading) {
                                Text("Comida")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(dailyPlan.lunch.name)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    
                    // Fila Cena
                    NavigationLink(destination: RecipeDetailView(recipe: dailyPlan.dinner)) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.purple)
                            VStack(alignment: .leading) {
                                Text("Cena")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(dailyPlan.dinner.name)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Funciones Lógicas
    
    func generateMenu() {
        // 1. Borrar cualquier menú anterior sucio
        deleteMenu()
        
        // 2. Llamar al algoritmo (MenuGenerator)
        let newMenu = MenuGenerator.generateWeekMenu(recipes: allRecipes, season: selectedSeason)
        
        // 3. Guardar cada día generado en la base de datos
        for dayPlan in newMenu {
            context.insert(dayPlan)
        }
    }
    
    func deleteMenu() {
        // Borrar todos los días del plan actual
        for item in weeklyMenu {
            context.delete(item)
        }
    }
}
