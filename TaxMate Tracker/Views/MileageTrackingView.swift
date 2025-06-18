//
//  MileageTrackingView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import SwiftUI
import SwiftData

struct MileageTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MileageEntry.startDate, order: .reverse) private var mileageEntries: [MileageEntry]
    @State private var showingAddSheet = false
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                mileageList
                    .navigationTitle(Text("Mileage Tracking"))
            }
            else {
                NavigationView {
                    mileageList
                        .navigationTitle(Text("Mileage Tracking"))
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddMileageTrackingFormView()
        }
        .overlay {
            if mileageEntries.isEmpty {
                EmptyStateView(
                    icon: "car",
                    title: "No mileage entries",
                    subtitle: "Track your business trips for tax deductions"
                )
            }
        }
        
    }
    
    @ViewBuilder
    private var mileageList: some View {
        List {
            ForEach(mileageEntries) { entry in
                MileageRowView(entry: entry)
            }
            .onDelete(perform: deleteMileageEntries)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .padding(5)
                        .background(.ultraThickMaterial)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private func deleteMileageEntries(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(mileageEntries[index])
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete mileage entry: \(error)")
        }
    }
}

struct MileageRowView: View {
    let entry: MileageEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(String(format: "%.1f miles", entry.distance))
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text(entry.startDate, style: .date)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            if !entry.purpose.isEmpty {
                Text(entry.purpose)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.accentGreen)
            }
            
            if !entry.startLocation.isEmpty || !entry.endLocation.isEmpty {
                Text("\(entry.startLocation) → \(entry.endLocation)")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
            }
            
            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text(entry.isBusinessTrip ? "Business" : "Personal")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(entry.isBusinessTrip ? AppTheme.accentGreen.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(entry.isBusinessTrip ? AppTheme.accentGreen : .gray)
                    .cornerRadius(4)
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MileageTrackingView()
}
