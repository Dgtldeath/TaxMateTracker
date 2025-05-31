//
//  EntryRowView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import SwiftUI

struct EntryRowView: View {
    let entry: ExpenseEntry
    
    var body: some View {
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
            
            Text(String(format: "%@$%.2f", entry.isIncome ? "+" : "-", entry.amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(entry.isIncome ? AppTheme.accentGreen : .red)
        }
        .padding(.vertical, 8)
    }
}
