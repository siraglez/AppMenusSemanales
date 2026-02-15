//
//  RegisterView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 15/2/26.
//

// Pantalla de registro al iniciar la aplicación

import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    @State private var name = ""
    @State private var surname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Crear Cuenta")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 15) {
                TextField("Nombre", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                
                TextField("Apellido(s)", text: $surname)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                
                TextField("Correo electrónico", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                
                SecureField("Contraseña", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            Button(action: registerUser) {
                Text("Registrarse")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(name.isEmpty || email.isEmpty || password.isEmpty)
            
            Spacer()
            
            Button("¿Ya tienes cuenta? Inicia Sesión") {
                dismiss() // Vuelve a la pantalla de login
            }
            .padding(.bottom)
        }
        .padding()
        .navigationBarBackButtonHidden(true) // Ocultar el botón nativo para usar el mío
    }
    
    func registerUser() {
        // Validación básica
        if password.count < 4 {
            errorMessage = "La contraseña es muy corta"
            return
        }
        // Encriptar contraseña antes de guardar al usuario
        let hashedPassword = SecurityHelper.hashPassword(password)
        
        let newUser = UserProfile(name: name, surname: surname, email: email, password: hashedPassword)
        context.insert(newUser)
        
        // Iniciamos sesión automáticamente
        isLoggedIn = true
    }
}
