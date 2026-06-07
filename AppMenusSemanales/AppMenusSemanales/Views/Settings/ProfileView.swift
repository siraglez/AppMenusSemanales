//
//  ProfileView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño
//
// Pantalla de perfil del usuario con ajustes
//
//  Sección "Mis Preferencias" que navega a PreferencesEditorView
//  para que el usuario pueda editar sus alergias/intolerancias/gustos en cualquier momento

import SwiftUI
import SwiftData
 
struct ProfileView: View {
    @Query var users: [UserProfile]
    @Environment(\.modelContext) var context
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    
    var body: some View {
        NavigationStack {
            Form {
                if let user = users.first {
                    
                    // ── Datos del usuario ──
                    Section("Mis Datos") {
                        Text("\(user.name) \(user.surname)")
                            .font(.headline)
                        Text(user.email)
                            .foregroundStyle(.secondary)
                        Text("Miembro desde: \(user.registerDate.formatted(date: .abbreviated, time: .omitted))")
                    }
                    
                    // ── Preferencias alimentarias ──
                    Section("Preferencias Alimentarias") {
                        NavigationLink(destination: PreferencesEditorView()
                            .navigationTitle("Mis Preferencias")
                            .navigationBarTitleDisplayMode(.inline)
                        ) {
                            Label("Alergias, intolerancias y gustos", systemImage: "heart.text.square")
                        }
                    }
                    
                    // ── Cuenta ──
                    Section("Cuenta") {
                        Button("Cerrar Sesión", role: .destructive) {
                            isLoggedIn = false
                        }
                        Button("Borrar Cuenta y Datos", role: .destructive) {
                            deleteAccount(user: user)
                        }
                    }
                    
                } else {
                    Text("No se encontró usuario")
                }
            }
            .navigationTitle("Perfil")
            .toolbar {
                Button(action: { }) {
                    Image(systemName: "gear")
                }
            }
        }
    }
    
    func deleteAccount(user: UserProfile) {
        context.delete(user)
        isLoggedIn = false
    }
}
