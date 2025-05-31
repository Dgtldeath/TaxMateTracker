//
//  QuickActionButton.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import SwiftUI

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppTheme.lightGray)
            .cornerRadius(AppTheme.cornerRadius)
        }
    }
}
