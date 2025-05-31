//
//  EmptyStateView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(AppTheme.textSecondary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
