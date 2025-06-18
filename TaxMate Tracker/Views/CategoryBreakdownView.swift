//
//  CategoryBreakdownView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 6/15/25.
//

import SwiftUI
import SwiftData


struct CategoryBreakdownView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var expenseEntries: [ExpenseEntry]
    
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var showBusinessOnly = true
    
    private var availableYears: [Int] {
        let years = expenseEntries.map { Calendar.current.component(.year, from: $0.date) }
        return Array(Set(years)).sorted(by: >)
    }
    
    private var filteredExpenses: [ExpenseEntry] {
        expenseEntries.filter { entry in
            !entry.isIncome &&
            Calendar.current.component(.year, from: entry.date) == selectedYear &&
            (showBusinessOnly ? true : true) // Add business logic if needed
        }
    }
    
    private var categoryTotals: [CategoryTotal] {
        let grouped = Dictionary(grouping: filteredExpenses, by: \.category)
        
        return grouped.compactMap { category, entries in
            let total = entries.reduce(0.0) { sum, entry in
                sum + calculateAnnualizedAmount(entry: entry)
            }
            return total > 0 ? CategoryTotal(category: category, amount: total, entries: entries) : nil
        }.sorted { $0.amount > $1.amount }
    }
    
    private var grandTotal: Double {
        categoryTotals.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filters
                VStack(spacing: 12) {
                    HStack {
                        Text("Tax Year:")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Picker("Year", selection: $selectedYear) {
                            ForEach(availableYears, id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                    }
                    
                    HStack {
                        Text("Business Expenses Only")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Toggle("", isOn: $showBusinessOnly)
                    }
                }
                .padding()
                .background(AppTheme.lightGray)
                .cornerRadius(AppTheme.cornerRadius)
                
                // Grand Total Card
                VStack(spacing: 8) {
                    Text("Total Business Deductions")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("$\(String(format: "%.2f", grandTotal))")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.accentGreen)
                    
                    Text("Tax Year \(selectedYear)")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.lightGray)
                .cornerRadius(AppTheme.cornerRadius)
                
                // Category List
                List {
                    ForEach(categoryTotals) { categoryTotal in
                        CategoryRowView(categoryTotal: categoryTotal)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .padding()
            .navigationTitle("Tax Category Breakdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Export") {
//                        exportCategoryBreakdown()
//                    }
//                }
            }
        }
    }
    
    private func calculateAnnualizedAmount(entry: ExpenseEntry) -> Double {
        let baseAmount = entry.amount
        
        switch entry.frequency {
        case .oneTime:
            return baseAmount
        case .weekly:
            return baseAmount * 52
        case .monthly:
            return baseAmount * 12
        case .annually:
            return baseAmount
        }
    }
    
    private func exportCategoryBreakdown() {
        // Implement CSV export for tax filing
        print("Exporting category breakdown for \(selectedYear)")
    }
}

struct CategoryTotal: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let entries: [ExpenseEntry]
}

struct CategoryRowView: View {
    let categoryTotal: CategoryTotal
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Category Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(categoryTotal.category)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(categoryTotal.entries.count) expense\(categoryTotal.entries.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", categoryTotal.amount))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Button(isExpanded ? "Hide Details" : "Show Details") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(AppTheme.accentGreen)
                }
            }
            
            // Expanded Details
            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(categoryTotal.entries) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.entryDescription.isEmpty ? "No description" : entry.entryDescription)
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Text("\(entry.date, style: .date) • \(entry.frequency.rawValue)")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("$\(String(format: "%.2f", entry.amount))")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                
                                if entry.frequency != .oneTime {
                                    Text("($\(String(format: "%.2f", calculateAnnualizedAmount(entry: entry))) annually)")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.accentGreen)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.lightGray.opacity(0.5))
                        .cornerRadius(6)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func calculateAnnualizedAmount(entry: ExpenseEntry) -> Double {
        switch entry.frequency {
        case .oneTime: return entry.amount
        case .weekly: return entry.amount * 52
        case .monthly: return entry.amount * 12
        case .annually: return entry.amount
        }
    }
}
