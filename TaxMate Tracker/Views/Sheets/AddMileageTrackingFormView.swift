//
//  AddMileageTrackingFormView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 6/1/25.
//


import SwiftUI
import SwiftData

struct AddMileageTrackingFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var distance: String = ""
    @State private var startLocation: String = ""
    @State private var endLocation: String = ""
    @State private var purpose = TripPurpose.clientMeeting
    @State private var notes: String = ""
    @State private var isBusinessTrip = true
    @State private var tripDate = Date()
    
    // UserDefaults for suggestions
    @AppStorage("lastMileageDistance") private var lastDistance: Double = 0.0
    @AppStorage("recentStartLocations") private var recentStartLocationsData: Data = Data()
    @AppStorage("recentEndLocations") private var recentEndLocationsData: Data = Data()
    
    // Computed properties for recent locations
    private var recentStartLocations: [String] {
        if let locations = try? JSONDecoder().decode([String].self, from: recentStartLocationsData) {
            return Array(locations.prefix(3)) // Keep last 3
        }
        return []
    }
    
    private var recentEndLocations: [String] {
        if let locations = try? JSONDecoder().decode([String].self, from: recentEndLocationsData) {
            return Array(locations.prefix(3)) // Keep last 3
        }
        return []
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Trip Details") {
                    DatePicker("Date", selection: $tripDate, displayedComponents: .date)
                    
                    Picker("Trip Type", selection: $isBusinessTrip) {
                        Text("Business").tag(true)
                        Text("Personal").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Purpose", selection: $purpose) {
                        ForEach(TripPurpose.allCases, id: \.self) { purpose in
                            Text(purpose.rawValue).tag(purpose)
                        }
                    }
                }
                
                Section("Distance") {
                    HStack {
                        TextField("0.0", text: $distance)
                            .keyboardType(.decimalPad)
                        Text("miles")
                            .foregroundColor(.secondary)
                    }
                    
                    if lastDistance > 0 {
                        Button("Use last distance: \(String(format: "%.1f", lastDistance)) mi") {
                            distance = String(format: "%.1f", lastDistance)
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.accentGreen.opacity(0.1))
                        .foregroundColor(AppTheme.accentGreen)
                        .cornerRadius(6)
                    }
                }
                
                Section("Locations") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("From (optional)", text: $startLocation)
                        
                        // ✅ Quick buttons for recent start locations
                        if !recentStartLocations.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(recentStartLocations, id: \.self) { location in
                                        Button(location) {
                                            startLocation = location
                                        }
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppTheme.accentGreen.opacity(0.1))
                                        .foregroundColor(AppTheme.accentGreen)
                                        .cornerRadius(6)
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("To (optional)", text: $endLocation)
                        
                        // ✅ Quick buttons for recent end locations
                        if !recentEndLocations.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(recentEndLocations, id: \.self) { location in
                                        Button(location) {
                                            endLocation = location
                                        }
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppTheme.accentGreen.opacity(0.1))
                                        .foregroundColor(AppTheme.accentGreen)
                                        .cornerRadius(6)
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Additional details...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Mileage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMileageEntry()
                    }
                    .disabled(distance.isEmpty || Double(distance) == nil || Double(distance)! <= 0)
                }
            }
        }
    }
    
    private func saveMileageEntry() {
        guard let distanceValue = Double(distance), distanceValue > 0 else { return }
        
        let mileageEntry = MileageEntry(
            startDate: tripDate,
            distance: distanceValue,
            startLocation: startLocation,
            endLocation: endLocation,
            purpose: purpose.rawValue,
            notes: notes,
            isBusinessTrip: isBusinessTrip
        )
        
        mileageEntry.endDate = tripDate
        modelContext.insert(mileageEntry)
        
        // Save distance for next time
        lastDistance = distanceValue
        
        // ✅ Save locations for quick access
        saveRecentLocation(startLocation, to: \.recentStartLocationsData)
        saveRecentLocation(endLocation, to: \.recentEndLocationsData)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save mileage entry: \(error)")
        }
    }
    
    // ✅ Helper function to save recent locations
    private func saveRecentLocation(_ location: String, to keyPath: ReferenceWritableKeyPath<AddMileageTrackingFormView, Data>) {
        guard !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var locations: [String]
        if let existing = try? JSONDecoder().decode([String].self, from: self[keyPath: keyPath]) {
            locations = existing
        } else {
            locations = []
        }
        
        // Remove if already exists (to move to front)
        locations.removeAll { $0.lowercased() == trimmedLocation.lowercased() }
        
        // Add to front
        locations.insert(trimmedLocation, at: 0)
        
        // Keep only last 3
        locations = Array(locations.prefix(3))
        
        // Save back
        if let data = try? JSONEncoder().encode(locations) {
            self[keyPath: keyPath] = data
        }
    }
}

#Preview {
    AddMileageTrackingFormView()
}
