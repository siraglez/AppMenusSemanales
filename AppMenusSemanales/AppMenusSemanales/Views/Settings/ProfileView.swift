//
//  ProfileView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//
// Pantalla de perfil del usuario con ajustes

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query var users: [UserProfile] // Recuperamos el usuario guardado
    @Environment(\.modelContext) var context
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    
    var body: some View{
        NavigationStack {
                    Form {
                        if let user = users.first {
                            Section("Mis Datos") {
                                Text(user.name)
                                Text(user.email).foregroundStyle(.secondary)
                                Text("Miembro desde: \(user.registerDate.formatted(date: .abbreviated, time: .omitted))")
                            }
                            
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
                        Button(action: { /* Acción de ajustes futura */ }) {
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
