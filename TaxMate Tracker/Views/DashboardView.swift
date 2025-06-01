//
//  DashboardView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import SwiftUI
import SwiftData

// MARK: - Dashboard View
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var expenseEntries: [ExpenseEntry]
    @Query private var mileageEntries: [MileageEntry]
    @State private var showingMileageSheet = false
    
    private var monthlyIncome: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return expenseEntries
            .filter { $0.isIncome && $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var monthlyExpenses: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return expenseEntries
            .filter { !$0.isIncome && $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var monthlyMileage: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return mileageEntries
            .filter { $0.startDate >= startOfMonth }
            .reduce(0) { $0 + $1.distance }
    }
    
    private var mileageYTD: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
        
        return mileageEntries
            .filter { $0.startDate >= startOfYear && $0.isBusinessTrip }
            .reduce(0) { $0 + $1.distance }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.spacing) {
                    // Summary Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: AppTheme.spacing) {
                        SummaryCard(
                            title: "Monthly Income",
                            value: monthlyIncome,
                            icon: "dollarsign.circle.fill",
                            color: AppTheme.accentGreen
                        )
                        
                        SummaryCard(
                            title: "Monthly Expenses",
                            value: monthlyExpenses,
                            icon: "minus.circle.fill",
                            color: .red
                        )
                        
                        SummaryCard(
                            title: "Mileage YTD",
                            value: mileageYTD,
                            icon: "speedometer",
                            color: .blue,
                            isDistance: true
                        )
                        
                        SummaryCard(
                            title: "Net Income",
                            value: monthlyIncome - monthlyExpenses,
                            icon: "chart.line.uptrend.xyaxis",
                            color: monthlyIncome - monthlyExpenses >= 0 ? AppTheme.accentGreen : .red
                        )
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        HStack(spacing: 12) {
                            QuickActionButton(
                                title: "Add Expense",
                                icon: "minus.circle",
                                color: .red
                            ) {
                                // Navigate to Add Entry
                            }
                            
                            QuickActionButton(
                                title: "Add Income",
                                icon: "plus.circle",
                                color: AppTheme.accentGreen
                            ) {
                                // Navigate to Add Entry
                            }
                            
                            QuickActionButton(
                                title: "Track Miles",
                                icon: "car",
                                color: .blue
                            ) {
                                // Navigate to Mileage Tracking and show sheet
                                showingMileageSheet = true
                            }
                        }
                    }
                    
                    // Recent Entries Preview
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Entries")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            Button("View All") {
                                // Navigate to full list
                            }
                            .foregroundColor(AppTheme.accentGreen)
                        }
                        
                        if expenseEntries.isEmpty {
                            EmptyStateView(
                                icon: "doc.text",
                                title: "No entries yet",
                                subtitle: "Start tracking your business expenses and income"
                            )
                        } else {
                            ForEach(Array(expenseEntries.prefix(3).enumerated()), id: \.element.id) { index, entry in
                                EntryRowView(entry: entry)
                            }
                        }
                    }
                }
                .padding(AppTheme.spacing)
            }
            .navigationTitle("TaxMate Tracker")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingMileageSheet) {
                AddMileageTrackingFormView()
            }
        }
    }
}
