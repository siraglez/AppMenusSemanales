//
//  PreferencesEditorView.swift
//  AppMenusSemanales
//
//  Created by Sira González-Madroño
//
//  Vista reutilizable para editar alergias, intolerancias y preferencias.
//  Se usa tanto en el onboarding (primera vez) como en la pantalla de Perfil.
//
//  CÓMO FUNCIONA:
//  - En .onAppear crea el objeto UserPreferences en la BD si no existe aún
//  - Permite añadir/borrar alergias, intolerancias y alimentos no deseados
//  - Las intolerancias más comunes se muestran como botones de acceso rápido

import SwiftUI
import SwiftData

struct PreferencesEditorView: View {
    @Environment(\.modelContext) var context
    
    // Traemos las preferencias de la BD (solo habrá una)
    @Query var allPreferences: [UserPreferences]
    
    var member: FamilyMember? = nil
    
    // Campos de texto para añadir nuevos items
    @State private var newAllergyText    = ""
    @State private var newIntoleranceText = ""
    @State private var newDislikeText    = ""
    
    // Intolerancias más comunes para acceso rápido (botones)
    let commonIntolerances = ["Lactosa", "Gluten", "Fructosa", "Sorbitol", "Histamina", "FODMAP"]
    
    // Devuelve las preferencias correctas según haya miembro o no
    var preferences: UserPreferences? {
        if let member {
            return member.preferences
        } else {
            return allPreferences.first { $0.member == nil }
        }
    }
    
    var body: some View {
        Form {
            if let prefs = preferences {
                
                // ──────────────────────────────────────────
                // SECCIÓN 1: ALERGIAS (rojo)
                // ──────────────────────────────────────────
                Section {
                    Text("Las recetas que contengan estos ingredientes serán excluidas completamente del menú generado.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        TextField("Ej: cacahuete, marisco...", text: $newAllergyText)
                            .autocorrectionDisabled()
                        Button(action: addAllergen) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.red)
                                .font(.title2)
                        }
                        .buttonStyle(.borderless)
                        .disabled(newAllergyText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    
                    ForEach(prefs.allergies, id: \.self) { allergen in
                        Label(allergen, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                    .onDelete { prefs.allergies.remove(atOffsets: $0) }
                    
                    if prefs.allergies.isEmpty {
                        Text("Sin alergias registradas")
                            .foregroundStyle(.secondary).font(.caption)
                    }
                } header: {
                    Label("Alergias", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
                
                // ──────────────────────────────────────────
                // SECCIÓN 2: INTOLERANCIAS (naranja)
                // ──────────────────────────────────────────
                Section {
                    Text("Las recetas con estos ingredientes se incluirán en el menú, pero recibirás un aviso para adaptarlas (ej: usar leche sin lactosa).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("Añadir rápidamente:").font(.caption).foregroundStyle(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(commonIntolerances, id: \.self) { intolerance in
                                if !prefs.intolerances.contains(intolerance) {
                                    Button(intolerance) {
                                        prefs.intolerances.append(intolerance)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.orange)
                                    .font(.caption)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    HStack {
                        TextField("Ej: lactosa, gluten...", text: $newIntoleranceText)
                            .autocorrectionDisabled()
                        Button(action: addIntolerance) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.orange)
                                .font(.title2)
                        }
                        .buttonStyle(.borderless)
                        .disabled(newIntoleranceText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    
                    ForEach(prefs.intolerances, id: \.self) { intolerance in
                        Label(intolerance, systemImage: "exclamationmark.circle.fill")
                            .foregroundStyle(.orange)
                    }
                    .onDelete { prefs.intolerances.remove(atOffsets: $0) }
                    
                    if prefs.intolerances.isEmpty {
                        Text("Sin intolerancias registradas")
                            .foregroundStyle(.secondary).font(.caption)
                    }
                } header: {
                    Label("Intolerancias", systemImage: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                }
                
                // ──────────────────────────────────────────
                // SECCIÓN 3: NO ME GUSTA (gris/suave)
                // ──────────────────────────────────────────
                Section {
                    Text("Recibirás un aviso suave cuando una receta contenga estos ingredientes. La receta se incluirá igualmente en el menú.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        TextField("Ej: cebolla, pimiento...", text: $newDislikeText)
                            .autocorrectionDisabled()
                        Button(action: addDislike) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.secondary)
                                .font(.title2)
                        }
                        .buttonStyle(.borderless)
                        .disabled(newDislikeText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    
                    ForEach(prefs.dislikes, id: \.self) { dislike in
                        Label(dislike, systemImage: "hand.thumbsdown.fill")
                            .foregroundStyle(.secondary)
                    }
                    .onDelete { prefs.dislikes.remove(atOffsets: $0) }
                    
                    if prefs.dislikes.isEmpty {
                        Text("Sin preferencias registradas")
                            .foregroundStyle(.secondary).font(.caption)
                    }
                } header: {
                    Label("No me gusta", systemImage: "hand.thumbsdown.fill")
                }
                
            } else {
                ProgressView("Cargando preferencias...")
            }
        }
        .onAppear { ensurePreferencesExist() }
    }
    
    // Crea el objeto de preferencias si no existe (global o del miembro)
    func ensurePreferencesExist() {
        if let member {
            // Preferencias de un miembro concreto
            if member.preferences == nil {
                let new = UserPreferences()
                context.insert(new)
                member.preferences = new
            }
        } else {
            // Preferencias globales del usuario principal
            if !allPreferences.contains(where: { $0.member == nil }) {
                context.insert(UserPreferences())
            }
        }
    }
    
    // MARK: - Funciones para añadir items
    func addAllergen() {
        let trimmed = newAllergyText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let prefs = preferences else { return }
        if !prefs.allergies.contains(trimmed.capitalized) { prefs.allergies.append(trimmed.capitalized) }
        newAllergyText = ""
    }
    
    func addIntolerance() {
        let trimmed = newIntoleranceText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let prefs = preferences else { return }
        if !prefs.intolerances.contains(trimmed.capitalized) { prefs.intolerances.append(trimmed.capitalized) }
        newIntoleranceText = ""
    }
    
    func addDislike() {
        let trimmed = newDislikeText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let prefs = preferences else { return }
        if !prefs.dislikes.contains(trimmed.capitalized) { prefs.dislikes.append(trimmed.capitalized) }
        newDislikeText = ""
    }
}
