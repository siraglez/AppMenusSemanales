//
//  LoginView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 13/2/26.
//

// Pantalla de login y registro al iniciar la aplicación

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) var context
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false // Guarda el estado en el móvil
    
    @State private var name = ""
    @State private var email = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.blue)
            
            Text("Bienvenido a tu Menú")
                .font(.largeTitle)
                .bold()
            
            VStack(alignment: .leading) {
                TextField("Nombre", text: $name)
                    .textFieldStyle(.roundedBorder)
                TextField("Correo electrónico", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
            }
            .padding()
            
            Button(action: registerUser) {
                Text("Entrar / Registrarse")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(name.isEmpty || email.isEmpty)
        }
    }
    
    func registerUser() {
        // 1. Guardar el usuario en SwiftData
        let newUser = UserProfile(name: name, email: email)
        context.insert(newUser)
        
        // 2. Marcar que ha iniciado sesión para siempre
        isLoggedIn = true
    }
}
