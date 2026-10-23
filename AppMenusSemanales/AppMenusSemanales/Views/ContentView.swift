//
//  ContentView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño 
//
// La pantalla principal

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(DataStores.self) private var stores
    
    // Espacio activo (Familiar / Personal). Decide qué almacén ven las pestañas
    @AppStorage("currentSpace") private var currentSpaceRaw: String = MenuSpace.familiar.rawValue
    private var currentSpace: MenuSpace { MenuSpace(rawValue: currentSpaceRaw) ?? .familiar }
    
    @State private var selectedTab = 2
    // Semana compartida entre el planificador y la lista de la compra
    @State private var selectedWeek = Date()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RecipeListView()
                .modelContainer(stores.container(for: currentSpace))
                .id(currentSpaceRaw) // al cambiar de espacio, la pantalla se recarga con el otro almacén
                .tabItem {
                    Label("Recetas", systemImage: "fork.knife")
                }
                .tag(1)
            
            WeeklyPlanView(selectedTab: $selectedTab, selectedDate: $selectedWeek)
                .modelContainer(stores.container(for: currentSpace))
                .id(currentSpaceRaw)
                .tabItem {
                    Label("Planificador", systemImage: "calendar")
                }
                .tag(2)
            
            ShoppingListView(selectedDate: $selectedWeek)
                .modelContainer(stores.container(for: currentSpace))
                .id(currentSpaceRaw)
                .tabItem {
                    Label("Compra", systemImage: "cart")
                }
                .tag(3)
            
            // El perfil usa el almacén personal (mis preferencias son mías)
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.circle")
                }
                .tag(4)
        }
    }
}
