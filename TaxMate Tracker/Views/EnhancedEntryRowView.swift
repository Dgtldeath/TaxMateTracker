//
//  EnhancedEntryRowView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 6/14/25.
//

import SwiftUI

struct EnhancedEntryRowView: View {
    let entry: ExpenseEntry
    let onDeductibleCheck: (ExpenseEntry) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.entryDescription.isEmpty ? entry.category : entry.entryDescription)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(entry.category)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%@$%.2f", entry.isIncome ? "+" : "-", entry.amount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(entry.isIncome ? AppTheme.accentGreen : .red)
                    
                    Text(entry.frequency.rawValue)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    // Entry type badge
                    Text(entry.isIncome ? "Income" : "Expense")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(entry.isIncome ? AppTheme.accentGreen.opacity(0.2) : Color.red.opacity(0.2))
                        .foregroundColor(entry.isIncome ? AppTheme.accentGreen : .red)
                        .cornerRadius(4)
                }
            }
            
            // ONLY show deductible button for expenses (not income)
            if !entry.isIncome {
                HStack {
                    Spacer()
                    Button(action: {
                        onDeductibleCheck(entry)
                    }) {
                        Label("Ask if Deductible (-1 Coin)", systemImage: "sparkles")
                            .font(.caption)
                            .labelStyle(.titleAndIcon)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.accentGreen.opacity(0.1))
                    .foregroundColor(AppTheme.accentGreen)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
