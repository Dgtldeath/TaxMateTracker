//
//  ContentView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import SwiftUI
import SwiftData

// MARK: - Main Content View
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            CategoriesView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Categories")
                }
                .tag(1)
            
            AddEntryView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Entry")
                }
                .tag(2)
            
            MileageTrackingView()
                .tabItem {
                    Image(systemName: "car.fill")
                    Text("Mileage")
                }
                .tag(3)
            
            ReportsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Reports")
                }
                .tag(4)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(5)
        }
        .accentColor(AppTheme.accentGreen)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
