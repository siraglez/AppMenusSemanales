//
//  ContentView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//
// La pantalla principal

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 2
    // Semana compartida entre el Planificador y la Lista de la compra
    @State private var selectedWeek = Date()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RecipeListView()
                .tabItem {
                    Label("Recetas", systemImage: "fork.knife")
                }
                .tag(1)
            
            WeeklyPlanView(selectedTab: $selectedTab, selectedDate: $selectedWeek)
                .tabItem {
                    Label("Planificador", systemImage: "calendar")
                }
                .tag(2)
            
            ShoppingListView(selectedDate: $selectedWeek)
                .tabItem {
                    Label("Compra", systemImage: "cart")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.circle")
                }
                .tag(4)
        }
    }
}
