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
    @State private var showingExpenseSheet = false
    @State private var showingIncomeSheet = false
    @State private var showingAllEntries = false
    
    private var monthlyIncome: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return expenseEntries
            .filter { $0.isIncome && $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var totalSideIncome: Double {
        return expenseEntries
            .filter { $0.isIncome }
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
    
    private var expensesYTD: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
        
        return expenseEntries
            .filter { !$0.isIncome && $0.date >= startOfYear }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var incomeYTD: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
        
        return expenseEntries
            .filter { $0.isIncome && $0.date >= startOfYear }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var netIncomeYTD: Double {
        return incomeYTD - expensesYTD
    }
    
    var body: some View {
        
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad: No NavigationView (NavigationSplitView provides it)
                dashboardContent
                    .navigationTitle("TaxMate Tracker")
                    .navigationBarTitleDisplayMode(.large)
            } else {
                // iPhone: Needs NavigationView for TabView
                NavigationView {
                    dashboardContent
                        .navigationTitle("TaxMate Tracker")
                        .navigationBarTitleDisplayMode(.large)
                }
            }
        }
        .sheet(isPresented: $showingMileageSheet) {
            AddMileageTrackingFormView()
        }
        .sheet(isPresented: $showingExpenseSheet) {
            AddExpenseFormView()
        }
        .sheet(isPresented: $showingIncomeSheet) {
            AddIncomeFormView()
        }
        .sheet(isPresented: $showingAllEntries) {
            AllEntriesView()
        }
        
    }
    
    @ViewBuilder
    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacing) {
                // Summary Cards with enhanced styling
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: AppTheme.spacing) {
                    
                    // Income Card - Special styling for positive value
                    AnimatedSummaryCard(
                        title: "Income YTD",
                        value: incomeYTD,
                        icon: "dollarsign.circle.fill",
                        color: AppTheme.accentGreen,
                        animationDelay: 0.1
                    )
                    .overlay(
                        // Success accent for income
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(AppTheme.accentGreen.opacity(0.4), lineWidth: 2)
                            .opacity(incomeYTD > 0 ? 1 : 0)
                    )
                    
                    // Expenses Card - Warning styling
                    AnimatedSummaryCard(
                        title: "Expenses YTD",
                        value: expensesYTD,
                        icon: "minus.circle.fill",
                        color: .red,
                        animationDelay: 0.2
                    )
                    .overlay(
                        // Alert accent for expenses
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1.5)
                            .opacity(expensesYTD > 1000 ? 1 : 0) // Show if expenses are high
                    )
                    
                    // Mileage Card - Info styling
                    AnimatedSummaryCard(
                        title: "Mileage YTD",
                        value: mileageYTD,
                        icon: "speedometer",
                        color: .blue,
                        isDistance: true,
                        animationDelay: 0.3
                    )
                    .background(
                        // Subtle blue tint for mileage
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(Color.blue.opacity(0.05))
                    )
                    
                    // Net Income Card - Dynamic styling based on value
                    AnimatedSummaryCard(
                        title: "Net Income YTD",
                        value: netIncomeYTD,
                        icon: netIncomeYTD >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis",
                        color: netIncomeYTD >= 0 ? AppTheme.accentGreen : .red,
                        animationDelay: 0.4
                    )
                    .background(
                        // Dynamic background based on profit/loss
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(
                                (netIncomeYTD >= 0 ? AppTheme.accentGreen : Color.red)
                                    .opacity(0.08)
                            )
                    )
                    .overlay(
                        // Prominent border for net income
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        (netIncomeYTD >= 0 ? AppTheme.accentGreen : Color.red).opacity(0.6),
                                        (netIncomeYTD >= 0 ? AppTheme.accentGreen : Color.red).opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                }
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack(spacing: 12) {
                        AnimatedQuickActionButton(
                            title: "Add Expense",
                            icon: "minus.circle",
                            color: .red,
                            animationDelay: 0.1
                        ) {
                            showingExpenseSheet = true
                        }
                        
                        AnimatedQuickActionButton(
                            title: "Add Side Income",
                            icon: "plus.circle",
                            color: AppTheme.accentGreen,
                            animationDelay: 0.2
                        ) {
                            showingIncomeSheet = true
                        }
                        
                        AnimatedQuickActionButton(
                            title: "Track Miles",
                            icon: "car",
                            color: .blue,
                            animationDelay: 0.3
                        ) {
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
                            showingAllEntries = true
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
        .padding(AppTheme.spacing)
    }
}

struct AnimatedQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let animationDelay: Double
    let action: () -> Void
    
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.0
    @State private var iconRotation: Double = 0.0
    @State private var showButton = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            // Tap animation
            withAnimation(.easeInOut(duration: 0.1)) {
                scale = 0.95
            }
            withAnimation(.easeInOut(duration: 0.1).delay(0.1)) {
                scale = 1.0
            }
            
            action()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    // Animated glow background
                    Circle()
                        .fill(color.opacity(glowOpacity))
                        .frame(width: 35, height: 35)
                        .blur(radius: 4)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                    
                    // Icon background
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Animated icon
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                        .rotationEffect(.degrees(iconRotation))
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .scaleEffect(scale)
            .opacity(showButton ? 1 : 0)
            .offset(y: showButton ? 0 : 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(
                    color: color.opacity(glowOpacity * 0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [
                            color.opacity(0.3),
                            color.opacity(0.1),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .onAppear {
            // Entrance animation
            withAnimation(.easeOut(duration: 0.6).delay(animationDelay)) {
                showButton = true
            }
            
            // Start continuous animations after entrance
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay + 0.8) {
                startContinuousAnimations()
            }
        }
    }
    
    private func startContinuousAnimations() {
        // Gentle pulsing glow effect
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            isAnimating = true
            glowOpacity = 0.4
        }
        
        // Subtle icon animation based on type
        switch icon {
        case "car":
            // Gentle wiggle for car
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                iconRotation = 5
            }
        case "plus.circle":
            // Gentle scale for plus
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.5)) {
                iconRotation = 0 // Reset rotation, use scale instead
            }
        case "minus.circle":
            // Subtle bounce for minus
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true).delay(1.0)) {
                iconRotation = -3
            }
        default:
            break
        }
    }
}

struct AnimatedSummaryCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    var isDistance: Bool = false
    let animationDelay: Double
    
    @State private var showCard = false
    @State private var animateValue = false
    @State private var pulseIcon = false
    @State private var displayValue: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    // Animated background for icon
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 32, height: 32)
                        .scaleEffect(pulseIcon ? 1.1 : 1.0)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .scaleEffect(pulseIcon ? 1.05 : 1.0)
                }
                
                Spacer()
                
                // Trending indicator for Net Income
                if title.contains("Net Income") {
                    Image(systemName: value >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption)
                        .foregroundColor(value >= 0 ? AppTheme.accentGreen : .red)
                        .opacity(showCard ? 1 : 0)
                }
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textSecondary)
                .opacity(showCard ? 1 : 0)
            
            // Animated value
            Text(isDistance ? String(format: "%.1f mi", displayValue) : String(format: "$%.2f", displayValue))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
                .opacity(showCard ? 1 : 0)
                .onAppear {
                    // Animate the number counting up
                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay + 0.3) {
                        withAnimation(.easeOut(duration: 1.2)) {
                            displayValue = value
                        }
                    }
                }
        }
        .padding()
        .background(
            ZStack {
                // Base background with subtle gradient
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.lightGray,
                                AppTheme.lightGray.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Subtle colored accent border
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .opacity(showCard ? 1 : 0)
            }
        )
        .shadow(
            color: color.opacity(showCard ? 0.15 : 0.05),
            radius: showCard ? 6 : 2,
            x: 0,
            y: showCard ? 4 : 2
        )
        .scaleEffect(showCard ? 1 : 0.8)
        .opacity(showCard ? 1 : 0)
        .onAppear {
            // Staggered card entrance
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(animationDelay)) {
                showCard = true
            }
            
            // Start icon pulsing after card appears
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay + 1.0) {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulseIcon = true
                }
            }
        }
    }
}
