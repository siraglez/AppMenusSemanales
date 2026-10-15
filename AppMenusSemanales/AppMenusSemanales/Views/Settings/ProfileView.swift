//
//  ProfileView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño
//
// Pantalla de perfil: nombre, preferencias, recetas fijas y grupo familiar.
// La app no tiene cuentas: los datos son locales

import SwiftUI

struct ProfileView: View {
    @AppStorage("myName") var myName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // - Nombre -
                Section {
                    TextField("Tu nombre (opcional)", text: $myName)
                } header: {
                    Text("Mi nombre")
                } footer: {
                    Text("Se usa para identificar tus avisos en el menú familiar. Si lo dejas vacío, apareceras como \"Tú\".")
                }
                
                // - Preferencias alimentarias -
                Section("Preferencias Alimentarias") {
                    NavigationLink(destination: PreferencesEditorView()
                        .navigationTitle("Mis Preferencias")
                        .navigationBarTitleDisplayMode(.inline)
                    ) {
                        Label("Alergias, intolerancias y gustos", systemImage: "heart.text.square")
                    }
                }
                
                // - Recetas fijas -
                Section("Recetas Fijas") {
                    NavigationLink(destination: FixedRecipesEditorView()
                        .navigationTitle("Recetas Fijas")
                        .navigationBarTitleDisplayMode(.inline)
                    ) {
                        Label("Recetas fijas por día", systemImage: "pin")
                    }
                }
                
                // - Grupo familiar -
                Section("Grupo Familiar") {
                    NavigationLink(destination: FamilyMembersEditorView()) {
                        Label("Miembros de la familia", systemImage: "person.3")
                    }
                }
            }
            .navigationTitle("Perfil")
            .toolbar {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
                .accessibilityLabel("Ajustes")
            }
        }
    }
}
