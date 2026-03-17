//
//  ContentView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// La pantalla principal

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 2
    
    var body: some View {
        // Usar un TabView para tener navegación abajo
        TabView(selection: $selectedTab) {
            // Pestaña 1: Recetas
            RecipeListView()
                .tabItem {
                    Label("Recetas", systemImage: "fork.knife")
                }
                .tag(1)
            
            // Pestaña 2: Planificador (PANTALLA PRINCIPAL POR DEFECTO)
            WeeklyPlanView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Planificador", systemImage: "calendar")
                }
                .tag(2)
            
            // Pestaña 3: Lista de la compra
            ShoppingListView()
                .tabItem {
                    Label("Compra", systemImage: "cart")
                }
                .tag(3)
            
            // Pestaña 4: Perfil
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.circle")
                }
                .tag(4)
        }
    }
}
