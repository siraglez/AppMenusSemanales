//
//  LoginView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//

// Pantalla de login al iniciar la aplicación

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) var context
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false // Guarda el estado en el móvil
    
    // Consultar los usuarios guardados para comprobar las credenciales
    @Query var registeredUsers: [UserProfile]
    
    @State private var password = ""
    @State private var email = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
            NavigationStack {
                VStack(spacing: 25) {
                    Spacer()
                    
                    Image(systemName: "faceid")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                    
                    Text("Bienvenido")
                        .font(.largeTitle)
                        .bold()
                    
                    // Formulario normal
                    VStack(spacing: 15) {
                        TextField("Correo electrónico", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Contraseña", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)
                    
                    if showError {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                    
                    // Botón de login con contraseña
                    Button(action: loginWithPassword) {
                        Text("Iniciar Sesión")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // --- Botón de Face ID ---
                    // Solo se muestra si ya existe algún usuario registrado
                    if !registeredUsers.isEmpty {
                        HStack {
                            Rectangle().frame(height: 1).foregroundStyle(.gray.opacity(0.3))
                            Text("O").font(.caption).foregroundStyle(.gray)
                            Rectangle().frame(height: 1).foregroundStyle(.gray.opacity(0.3))
                        }
                        .padding(.horizontal)
                        
                        Button(action: loginWithFaceID) {
                            HStack {
                                Image(systemName: "faceid")
                                Text("Entrar con Face ID")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Link al registro
                    NavigationLink(destination: RegisterView()) {
                        HStack {
                            Text("¿No tienes cuenta?")
                                .foregroundStyle(.secondary)
                            Text("Regístrate")
                                .bold()
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
        }
        
    // Lógica 1: Contraseña manual
        func loginWithPassword() {
            // 1. Encriptar lo que el usuario acaba de escribir
            let inputHash = SecurityHelper.hashPassword(password)
            
            // 2. Buscar si existe algún usuario con ese email y contraseña
            if let _ = registeredUsers.first(where: { $0.email == email && $0.password == inputHash }) {
                isLoggedIn = true
                showError = false
            } else {
                errorMessage = "Correo o contraseña incorrectos"
                showError = true
            }
        }
    
    // Lógica 2: Face ID
    func loginWithFaceID() {
        BiometricHelper.authenticateUser { success, error in
            if success {
                isLoggedIn = true
            } else {
                errorMessage = error ?? "Error de Face ID"
                showError = true
            }
        }
    }
}
