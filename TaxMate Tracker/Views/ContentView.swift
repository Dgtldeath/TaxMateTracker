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
    @State private var showingOnboarding = false
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad: Use NavigationSplitView
                iPadLayout
                
            } else {
                // iPhone: Use TabView
                iPhoneLayout
            }
        }
        .accentColor(AppTheme.accentGreen)
        .onAppear {
            if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                showingOnboarding = true
            }
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView()
        }
    }
    
    @ViewBuilder
    private var iPadLayout: some View {
        NavigationSplitView {
            List {
                NavigationLink(destination: DashboardView()) {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
                
                NavigationLink(destination: MileageTrackingView()) {
                    Label("Mileage", systemImage: "car.fill")
                }
                .tag(1)
                
                NavigationLink(destination: AddEntryView()) {
                    Label("Add Entry", systemImage: "plus.circle.fill")
                }
                .tag(2)
                
                NavigationLink(destination: ReportsView()) {
                    Label("Reports", systemImage: "chart.bar.fill")
                }
                .tag(3)
                
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
            }
            .navigationTitle("TaxMate")
            .listStyle(SidebarListStyle())
        } detail: {
            // Default content for iPad with full width
            DashboardView()
                .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ Force full width
                .navigationBarHidden(false)
        }
        .navigationSplitViewStyle(.balanced) // ✅ Use balanced style for better width distribution
    }
    
    @ViewBuilder
    private var iPhoneLayout: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            MileageTrackingView()
                .tabItem {
                    Image(systemName: "car.fill")
                    Text("Mileage")
                }
                .tag(1)
            
            AddEntryView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Entry")
                }
                .tag(2)
            
            ReportsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Reports")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
    }
}
