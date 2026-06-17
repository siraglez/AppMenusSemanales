//
//  FamilyMembersEditorView.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 17/06/2026.
//
// Pantalla para gestionar los miembros de la unidad familiar
// Se accede desde el perfil. Cada miembro tiene nombre, marca de "en casa" y sus propias preferencias alimentarias

import SwiftUI
import SwiftData

struct FamilyMembersEditorView: View {
    @Environment(\.modelContext) var context
    @Query var members: [FamilyMember]
    
    @State private var showAddSheet = false
    
    var body: some View {
        List {
            Section {
                Text("Añade a los miembros de tu familia y configura las preferencias de cada uno. Marca quién está en casa para que, más adelante, el menú y la lista de la compra se ajusten automáticamente.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if members.isEmpty {
                Section {
                    Text("Aún no has añadido miembros.")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section("Miembros") {
                    ForEach(members) { member in
                        NavigationLink(destination: FamilyMemberDetailView(member: member)) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                VStack(alignment: .leading) {
                                    Text(member.name.isEmpty ? "Sin nombre" : member.name)
                                        .fontWeight(.medium)
                                    Text(member.isAtHome ? "En casa" : "Fuera")
                                        .font(.caption)
                                        .foregroundStyle(member.isAtHome ? .green : .secondary)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteMembers)
                }
            }
        }
        .navigationTitle("Grupo Familiar")
        .toolbar {
            Button("Añadir", systemImage: "plus") { showAddSheet = true
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddFamilyMemberView().presentationDetents([.medium])
        }
    }
    
    func deleteMembers(at offsets: IndexSet) {
        for index in offsets {
            let member = members[index]
            // Borrar también sus preferencias asociadas para no dejar objetos huérfanos
            if let prefs = member.preferences { context.delete(prefs) }
            context.delete(member)
        }
    }
}

// MARK: - Detalle de un miembro
struct FamilyMemberDetailView: View {
    @Bindable var member: FamilyMember
    
    var body: some View {
        Form {
            Section("Datos") {
                TextField("Nombre", text: $member.name)
                // Toggle y NavigationLink en filas separadas para evitar conflictos de toque
                Toggle("Está en casa", isOn: $member.isAtHome)
            }
            
            Section("Preferencias") {
                NavigationLink(destination: PreferencesEditorView(member: member)
                    .navigationTitle(member.name.isEmpty ? "Preferencias" : "Preferencias de \(member.name)")
                    .navigationBarTitleDisplayMode(.inline)
                ) {
                    Label("Alergias, intolerancias y gustos", systemImage: "heart.text.square")
                }
            }
        }
        .navigationTitle(member.name.isEmpty ? "Miembro" : member.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Formulario para añadir un miembro
struct AddFamilyMemberView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Nuevo miembro") {
                    TextField("Nombre", text: $name)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Añadir miembro")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Añadir") {
                        let newMember = FamilyMember(name: name.trimmingCharacters(in: .whitespaces),
                                                     role: "Familiar")
                        context.insert(newMember)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

