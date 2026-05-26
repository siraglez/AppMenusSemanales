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
    
    // Campos de texto para añadir nuevos items
    @State private var newAllergyText    = ""
    @State private var newIntoleranceText = ""
    @State private var newDislikeText    = ""
    
    // Intolerancias más comunes para acceso rápido (botones)
    let commonIntolerances = ["Lactosa", "Gluten", "Fructosa", "Sorbitol", "Histamina", "FODMAP"]
    
    // Acceso conveniente al objeto de preferencias
    var preferences: UserPreferences? { allPreferences.first }
    
    var body: some View {
        Form {
            if let prefs = preferences {
                
                // ──────────────────────────────────────────
                // SECCIÓN 1: ALERGIAS (rojo)
                // ──────────────────────────────────────────
                Section {
                    // Explicación
                    Text("Las recetas que contengan estos ingredientes serán excluidas completamente del menú generado.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Campo para añadir
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
                    
                    // Lista de alergias añadidas
                    ForEach(prefs.allergies, id: \.self) { allergen in
                        Label(allergen, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                    .onDelete { indexSet in
                        prefs.allergies.remove(atOffsets: indexSet)
                    }
                    
                    if prefs.allergies.isEmpty {
                        Text("Sin alergias registradas")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    
                } header: {
                    Label("Alergias", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
                
                // ──────────────────────────────────────────
                // SECCIÓN 2: INTOLERANCIAS (naranja)
                // ──────────────────────────────────────────
                Section {
                    Text("Las recetas con estos ingredientes se incluirán en el menú, pero recibirás un aviso para que las adaptes (ej: usar leche sin lactosa, pasta sin gluten...).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Botones de acceso rápido para las más comunes
                    Text("Añadir rápidamente:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(commonIntolerances, id: \.self) { intolerance in
                                // Solo mostrar las que aún no están añadidas
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
                    
                    // Campo para añadir manualmente
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
                    
                    // Lista de intolerancias añadidas
                    ForEach(prefs.intolerances, id: \.self) { intolerance in
                        Label(intolerance, systemImage: "exclamationmark.circle.fill")
                            .foregroundStyle(.orange)
                    }
                    .onDelete { indexSet in
                        prefs.intolerances.remove(atOffsets: indexSet)
                    }
                    
                    if prefs.intolerances.isEmpty {
                        Text("Sin intolerancias registradas")
                            .foregroundStyle(.secondary)
                            .font(.caption)
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
                    
                    // Campo para añadir
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
                    
                    // Lista de alimentos no deseados
                    ForEach(prefs.dislikes, id: \.self) { dislike in
                        Label(dislike, systemImage: "hand.thumbsdown.fill")
                            .foregroundStyle(.secondary)
                    }
                    .onDelete { indexSet in
                        prefs.dislikes.remove(atOffsets: indexSet)
                    }
                    
                    if prefs.dislikes.isEmpty {
                        Text("Sin preferencias registradas")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    
                } header: {
                    Label("No me gusta", systemImage: "hand.thumbsdown.fill")
                }
                
            } else {
                // Mientras se crea el objeto en BD (instantáneo, casi nunca se ve)
                ProgressView("Cargando preferencias...")
            }
        }
        .onAppear {
            // Si no existe aún el objeto de preferencias, lo creamos
            if allPreferences.isEmpty {
                context.insert(UserPreferences())
            }
        }
    }
    
    // MARK: - Funciones para añadir items
    
    func addAllergen() {
        let trimmed = newAllergyText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let prefs = preferences else { return }
        // Evitar duplicados
        if !prefs.allergies.contains(trimmed.capitalized) {
            prefs.allergies.append(trimmed.capitalized)
        }
        newAllergyText = ""
    }
    
    func addIntolerance() {
        let trimmed = newIntoleranceText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let prefs = preferences else { return }
        if !prefs.intolerances.contains(trimmed.capitalized) {
            prefs.intolerances.append(trimmed.capitalized)
        }
        newIntoleranceText = ""
    }
    
    func addDislike() {
        let trimmed = newDislikeText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let prefs = preferences else { return }
        if !prefs.dislikes.contains(trimmed.capitalized) {
            prefs.dislikes.append(trimmed.capitalized)
        }
        newDislikeText = ""
    }
}
 
