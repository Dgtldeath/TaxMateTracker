//
//  TaxMate_TrackerApp.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import SwiftUI
import SwiftData
import CoreLocation


@main
struct TaxMate_TrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
                Item.self,
                ExpenseEntry.self,
                MileageEntry.self,
                Category.self,
                UserProfile.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
