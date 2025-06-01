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
    
    // UserDefaults for last distance suggestion
    @AppStorage("lastMileageDistance") private var lastDistance: Double = 0.0
    
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
                    
                    // Quick distance suggestion
                    if lastDistance > 0 {
                        Button("Use last distance: \(String(format: "%.1f", lastDistance)) mi") {
                            distance = String(format: "%.1f", lastDistance)
                        }
                        .foregroundColor(AppTheme.accentGreen)
                    }
                }
                
                Section("Locations") {
                    TextField("From (optional)", text: $startLocation)
                    TextField("To (optional)", text: $endLocation)
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
        
        // Save last distance for quick suggestion
        lastDistance = distanceValue
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save mileage entry: \(error)")
        }
    }
}

#Preview {
    AddMileageTrackingFormView()
}
