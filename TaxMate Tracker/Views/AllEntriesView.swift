//
//  AllEntriesView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 6/14/25.
//


import SwiftUI
import SwiftData

struct AllEntriesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExpenseEntry.date, order: .reverse) private var allEntries: [ExpenseEntry]
    
    @State private var selectedFilter = EntryFilter.all
    @State private var showingDeductibleChecker = false
    @State private var selectedExpense: ExpenseEntry?
    
    @StateObject private var coinManager = CoinManager()  // ✅ Add coin manager
    
    enum EntryFilter: String, CaseIterable {
        case all = "All"
        case expenses = "Expenses"
        case income = "Income"
    }
    
    private var filteredEntries: [ExpenseEntry] {
        switch selectedFilter {
        case .all:
            return allEntries
        case .expenses:
            return allEntries.filter { !$0.isIncome }
        case .income:
            return allEntries.filter { $0.isIncome }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(EntryFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // ✅ Coin Balance Display
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text("Coins Remaining: \(coinManager.currentCoins) Coins")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom, 8)
                
                // Entries List
                List {
                    ForEach(filteredEntries) { entry in
                        EnhancedEntryRowView(
                            entry: entry,
                            onDeductibleCheck: { expense in
                                print("DEBUG: Setting selectedExpense to: \(expense.category) - $\(expense.amount)")
                                print("DEBUG: expense.isIncome = \(expense.isIncome)")
                                
                                // Reset states first
                                showingDeductibleChecker = false
                                selectedExpense = nil
                                
                                // Small delay to ensure clean state
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    selectedExpense = expense
                                    showingDeductibleChecker = true
                                    print("DEBUG: Sheet should open now")
                                }
                            }
                        )
                    }
                    .onDelete(perform: deleteEntries)
                }
                .overlay {
                    if filteredEntries.isEmpty {
                        EmptyStateView(
                            icon: selectedFilter == .income ? "plus.circle" : "minus.circle",
                            title: "No Data",
                            subtitle: "No entries found"
                        )
                    }
                }
            }
            .navigationTitle("All Entries")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingDeductibleChecker) {
                Group {
                    if let expense = selectedExpense {
                        DeductibleCheckerView(expense: expense)
                    } else {
                        VStack {
                            Text("Error: No expense selected")
                            Text("This is a debug screen")
                            Button("Close") {
                                showingDeductibleChecker = false
                            }
                        }
                        .padding()
                    }
                }
            }
            .onChange(of: showingDeductibleChecker) { isShowing in
                print("DEBUG: showingDeductibleChecker changed to: \(isShowing)")
                if !isShowing {
                    // Clear selectedExpense when sheet closes
                    selectedExpense = nil
                }
            }
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        for index in offsets {
            let entryToDelete = filteredEntries[index]
            // Find the entry in the original array and delete it
            if let originalIndex = allEntries.firstIndex(where: { $0.id == entryToDelete.id }) {
                modelContext.delete(allEntries[originalIndex])
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete entry: \(error)")
        }
    }
}
