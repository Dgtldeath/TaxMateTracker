//
//  SettingsView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    
    @StateObject private var coinManager = CoinManager()
    @StateObject private var storeManager: StoreManager
    
    @State private var showingOnboarding = false
    @State private var showingCoinStore = false
    @State private var showingProfileEdit = false
    @State private var showingExportOptions = false
    @State private var animateElements = false
    
    // User profile (create if doesn't exist)
    private var currentProfile: UserProfile {
        if let profile = userProfiles.first {
            return profile
        } else {
            let newProfile = UserProfile()
            modelContext.insert(newProfile)
            try? modelContext.save()
            return newProfile
        }
    }
    
    init() {
        let coinManager = CoinManager()
        self._coinManager = StateObject(wrappedValue: coinManager)
        self._storeManager = StateObject(wrappedValue: StoreManager(coinManager: coinManager))
    }
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                settingsContent
                    .navigationTitle("Settings")
            }
            else {
                NavigationView {
                    settingsContent
                        .navigationTitle("Settings")
                        .navigationBarTitleDisplayMode(.large)
                }
            }
        }
        .onAppear {
            withAnimation {
                animateElements = true
            }
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView()
        }
        .sheet(isPresented: $showingCoinStore) {
            CoinStoreView(storeManager: storeManager, coinManager: coinManager)
        }
        .sheet(isPresented: $showingProfileEdit) {
            ProfileEditView(profile: currentProfile)
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView()
        }
    }
    
    @ViewBuilder
    private var settingsContent : some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                ProfileHeaderView(
                    profile: currentProfile,
                    coinBalance: coinManager.currentCoins,
                    onEditProfile: { showingProfileEdit = true },
                    onManageCoins: { showingCoinStore = true }
                )
                .opacity(animateElements ? 1 : 0)
                .offset(y: animateElements ? 0 : -20)
                .animation(.easeOut(duration: 0.6).delay(0.1), value: animateElements)
                
                // Quick Actions
                SettingsSectionView(title: "Quick Actions", icon: "bolt.fill", color: .orange) {
                    VStack(spacing: 0) {
                        SettingsRowView(
                            icon: "graduationcap.fill",
                            title: "Show App Tutorial",
                            subtitle: "Replay the onboarding experience",
                            color: .blue
                        ) {
                            showingOnboarding = true
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        SettingsRowView(
                            icon: "square.and.arrow.up.fill",
                            title: "Export Data",
                            subtitle: "Backup your financial records",
                            color: AppTheme.accentGreen
                        ) {
                            showingExportOptions = true
                        }
                    }
                }
                .opacity(animateElements ? 1 : 0)
                .offset(x: animateElements ? 0 : -20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: animateElements)
                
                // Account & Subscription
                SettingsSectionView(title: "Account & Subscription", icon: "person.crop.circle.fill", color: AppTheme.primaryNavy) {
                    VStack(spacing: 0) {
//                            SettingsRowView(
//                                icon: "crown.fill",
//                                title: "Subscription",
//                                subtitle: currentProfile.subscriptionTier.rawValue,
//                                color: .purple,
//                                showChevron: true
//                            ) {
//                                // Navigate to subscription management
//                                print("Manage subscription")
//                            }
                        
                        //Divider().padding(.leading, 60)
                        
                        SettingsRowView(
                            icon: "circle.fill",
                            title: "AI Analysis Coins",
                            subtitle: "\(coinManager.currentCoins) remaining",
                            color: .yellow,
                            showChevron: true
                        ) {
                            showingCoinStore = true
                        }
                    }
                }
                .opacity(animateElements ? 1 : 0)
                .offset(x: animateElements ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: animateElements)
                
                // App Preferences
//                    SettingsSectionView(title: "Preferences", icon: "gearshape.fill", color: .gray) {
//                        VStack(spacing: 0) {
//                            SettingsToggleRow(
//                                icon: "bell.fill",
//                                title: "Push Notifications",
//                                subtitle: "Expense reminders and tips",
//                                color: .red,
//                                isOn: Binding(
//                                    get: { currentProfile.notificationsEnabled },
//                                    set: { newValue in
//                                        currentProfile.notificationsEnabled = newValue
//                                        try? modelContext.save()
//                                    }
//                                )
//                            )
//
//                            Divider().padding(.leading, 60)
//
//                            SettingsRowView(
//                                icon: "icloud.fill",
//                                title: "iCloud Sync",
//                                subtitle: "Sync data across devices",
//                                color: .blue,
//                                showChevron: true
//                            ) {
//                                // Handle iCloud sync
//                                print("Manage iCloud sync")
//                            }
//                        }
//                    }
//                    .opacity(animateElements ? 1 : 0)
//                    .offset(y: animateElements ? 0 : 20)
//                    .animation(.easeOut(duration: 0.6).delay(0.4), value: animateElements)
                
                // Support & Info
                SettingsSectionView(title: "Support & Information", icon: "questionmark.circle.fill", color: .cyan) {
                    VStack(spacing: 0) {
                        SettingsRowView(
                            icon: "envelope.fill",
                            title: "Contact Support",
                            subtitle: "Get help with the app",
                            color: .blue,
                            showChevron: true
                        ) {
                            openSupportEmail()
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        SettingsRowView(
                            icon: "star.fill",
                            title: "Rate TaxMate Tracker",
                            subtitle: "Leave a review in the App Store",
                            color: .orange,
                            showChevron: true
                        ) {
                            openAppStoreReview()
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        SettingsRowView(
                            icon: "doc.text.fill",
                            title: "Privacy Policy",
                            subtitle: "How we protect your data",
                            color: .green,
                            showChevron: true
                        ) {
                            openPrivacyPolicy()
                        }
                        
                        Divider().padding(.leading, 60)
                        
                        SettingsRowView(
                            icon: "info.circle.fill",
                            title: "App Version",
                            subtitle: getAppVersion(),
                            color: .secondary,
                            showChevron: false
                        ) {
                            // No action for version
                        }
                    }
                }
                .opacity(animateElements ? 1 : 0)
                .offset(y: animateElements ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: animateElements)
                
                // Developer Section (Debug/Testing)
                #if DEBUG
//                    SettingsSectionView(title: "Developer", icon: "hammer.fill", color: .red) {
//                        VStack(spacing: 0) {
//                            SettingsRowView(
//                                icon: "arrow.clockwise.circle.fill",
//                                title: "Reset Onboarding",
//                                subtitle: "Clear onboarding flag",
//                                color: .orange
//                            ) {
//                                UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
//                            }
//
//                            Divider().padding(.leading, 60)
//
//                            SettingsRowView(
//                                icon: "plus.circle.fill",
//                                title: "Add Test Coins",
//                                subtitle: "Add 10 coins for testing",
//                                color: .yellow
//                            ) {
//                                coinManager.addCoins(10)
//                            }
//                        }
//                    }
//                    .opacity(animateElements ? 1 : 0)
//                    .animation(.easeOut(duration: 0.6).delay(0.6), value: animateElements)
                #endif
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
    
    // MARK: - Helper Functions
    private func openSupportEmail() {
        if let url = URL(string: "mailto:support@taxmatetracker.com?subject=TaxMate%20Tracker%20Support") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openAppStoreReview() {
        if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://taxmatetracker.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    private func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
}

// MARK: - Profile Header Component
struct ProfileHeaderView: View {
    let profile: UserProfile
    let coinBalance: Int
    let onEditProfile: () -> Void
    let onManageCoins: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Avatar
            Button(action: onEditProfile) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.primaryNavy, AppTheme.accentGreen],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Text(getInitials(from: profile.name))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 4) {
                        Text(profile.name.isEmpty ? "Tap to set name" : profile.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if !profile.businessName.isEmpty {
                            Text(profile.businessName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(profile.subscriptionTier.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(profile.subscriptionTier == .premium ? AppTheme.accentGreen.opacity(0.2) : Color.gray.opacity(0.2))
                            .foregroundColor(profile.subscriptionTier == .premium ? AppTheme.accentGreen : .gray)
                            .cornerRadius(4)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Coins Balance
            Button(action: onManageCoins) {
                HStack(spacing: 12) {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Analysis Coins")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("\(coinBalance) remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private func getInitials(from name: String) -> String {
        if name.isEmpty { return "?" }
        let components = name.components(separatedBy: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
}

// MARK: - Settings Section Component
struct SettingsSectionView<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.subheadline)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
}

// MARK: - Settings Row Component
struct SettingsRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var showChevron: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Toggle Row Component
struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
    }
}

// MARK: - Profile Edit View (Simple)
struct ProfileEditView: View {
    let profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String
    @State private var businessName: String
    
    init(profile: UserProfile) {
        self.profile = profile
        self._name = State(initialValue: profile.name)
        self._businessName = State(initialValue: profile.businessName)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Full Name", text: $name)
                    TextField("Business Name (Optional)", text: $businessName)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        profile.name = name
                        profile.businessName = businessName
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Export Options View (Placeholder)
struct ExportOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Options")
                    .font(.title)
                
                Text("Coming Soon!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Add export functionality here
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
