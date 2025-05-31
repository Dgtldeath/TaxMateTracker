//
//  SummaryCard.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import SwiftUI

// MARK: - Supporting Views
struct SummaryCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    var isDistance: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            
            Text(isDistance ? String(format: "%.1f mi", value) : String(format: "$%.2f", value))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding()
        .background(AppTheme.lightGray)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(radius: 2)
    }
}
