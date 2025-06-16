import SwiftUI
import SwiftData

struct AllEntriesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExpenseEntry.date, order: .reverse) private var allEntries: [ExpenseEntry]
    
    @State private var selectedFilter = EntryFilter.all
    @State private var showingDeductibleChecker = false
    @State private var selectedExpense: ExpenseEntry?
    
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
                
                // Entries List
                List {
                    ForEach(filteredEntries) { entry in
                        EnhancedEntryRowView(
                            entry: entry,
                            onDeductibleCheck: { expense in
                                selectedExpense = expense
                                showingDeductibleChecker = true
                            }
                        )
                    }
                    .onDelete(perform: deleteEntries)
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
                if let expense = selectedExpense {
                    DeductibleCheckerView(expense: expense)
                }
            }
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredEntries[index])
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete entry: \(error)")
        }
    }
}