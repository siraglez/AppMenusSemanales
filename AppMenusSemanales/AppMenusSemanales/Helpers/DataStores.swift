//
//  DataStores.swift
//  AppMenusSemanales
//
//  Created by Sira Gonzalez-Madroño on 23/10/2026.
//
// Los dos almacenes de datos de la app:
// - personal: mis datos, sincronizados con MI iCloud (SwiftData + CloudKit automático)
// - familiar: los datos de la familia. Se usará CKSyncEngine para poder compartirlos.

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class DataStores {
    // Contenedor de iCloud de la app
    static let cloudKitContainerID = "iCloud.com.siraglez.easybite"
    
    // Todos los modelos de la app (los dos almacenes usan los mismos)
    static let schema = Schema([
        Recipe.self,
        Ingredient.self,
        WeeklyMenu.self,
        ExtraItem.self,
        UserPreferences.self,
        FixedAssignment.self,
        FamilyMember.self
    ])
    
    let personal: ModelContainer
    let familiar: ModelContainer
    
    init() {
        do {
            // Almacén personal: SwiftData lo sincroniza solo con mi iCloud
            let personalConfig = ModelConfiguration(
                "Personal",
                schema: Self.schema,
                cloudKitDatabase: .private(Self.cloudKitContainerID)
            )
            personal = try ModelContainer(for: Self.schema, configurations: personalConfig)
            
            // Almacén familiar: SwiftData NO lo sincroniza
            let familiarConfig = ModelConfiguration(
                "Familiar",
                schema: Self.schema,
                cloudKitDatabase: .none
            )
            familiar = try ModelContainer(for: Self.schema, configurations: familiarConfig)
        } catch {
            fatalError("No se pudieron crear los almacenes de datos: \(error)")
        }
    }
    
    // Devuelve el almacén que corresponde a cada espacio
    func container(for space: MenuSpace) -> ModelContainer {
        space == .familiar ? familiar : personal
    }
    
    // Mis preferencias (alergias, etc.). Siempre viven en el almacén personal. Da igual el espacio en que estemos.
    func myPreferences() -> UserPreferences? {
        let all = (try? personal.mainContext.fetch(FetchDescriptor<UserPreferences>())) ?? []
        return all.first { $0.member == nil }
    }
}
