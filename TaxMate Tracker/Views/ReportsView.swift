//
//  ReportsView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import SwiftUI
import SwiftData
import Charts

struct ReportsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var expenseEntries: [ExpenseEntry]
    @Query private var mileageEntries: [MileageEntry]
    
    @State private var selectedPeriod = ReportPeriod.twelveMonths
    @State private var showBusinessOnly = true
    @State private var showingExportMenu = false
    
    @State private var showingCategoryBreakdown: Bool = false
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                reportContent
                    .navigationTitle("Reports")
            }
            else {
                NavigationView {
                    reportContent
                        .navigationTitle("Reports")
                }
            }
        }
        .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Export") {
//                        showingExportMenu = true
//                    }
//                }
        }
        .confirmationDialog("Export Data", isPresented: $showingExportMenu) {
            Button("Export Expenses") { exportData(type: .expenses) }
            Button("Export Income") { exportData(type: .income) }
            Button("Export All Data") { exportData(type: .all) }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingCategoryBreakdown) {
            CategoryBreakdownView()
        }
        
    }
    
    @ViewBuilder
    private var reportContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Filters Section
                FiltersSection(
                    selectedPeriod: $selectedPeriod,
                    showBusinessOnly: $showBusinessOnly
                )
                
                // Summary Cards
                ReportSummaryCards(
                    expenseTotal: filteredExpenseTotal,
                    incomeTotal: filteredIncomeTotal,
                    mileageTotal: filteredMileageTotal
                )
                
                // Charts
                ExpensesChart(data: expenseChartData)
                
                IncomeChart(data: incomeChartData)
                
                CategoryPieChart(data: categoryBreakdown,
                                 onViewBreakdown: { showingCategoryBreakdown = true }
                )
            }
            .padding()
        }
    }
    
    // MARK: - Computed Properties (keep all the existing ones)
    private var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let end = now
        
        let start: Date
        switch selectedPeriod {
        case .oneMonth:
            start = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .threeMonths:
            start = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case .sixMonths:
            start = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case .twelveMonths:
            start = calendar.date(byAdding: .month, value: -12, to: now) ?? now
        }
        
        return (start, end)
    }
    
    private var filteredExpenses: [ExpenseEntry] {
        let range = dateRange
        return expenseEntries.filter { entry in
            !entry.isIncome &&
            entry.date >= range.start &&
            entry.date <= range.end
        }
    }
    
    private var filteredIncome: [ExpenseEntry] {
        let range = dateRange
        return expenseEntries.filter { entry in
            entry.isIncome &&
            entry.date >= range.start &&
            entry.date <= range.end
        }
    }
    
    private var filteredExpenseTotal: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private var filteredIncomeTotal: Double {
        filteredIncome.reduce(0) { $0 + $1.amount }
    }
    
    private var filteredMileageTotal: Double {
        let range = dateRange
        return mileageEntries
            .filter { entry in
                entry.startDate >= range.start &&
                entry.startDate <= range.end &&
                (showBusinessOnly ? entry.isBusinessTrip : true)
            }
            .reduce(0) { $0 + $1.distance }
    }
    
    private var expenseChartData: [ChartDataPoint] {
        let sortedExpenses = filteredExpenses.sorted { $0.date < $1.date }
        var cumulative = 0.0
        var data: [ChartDataPoint] = []
        
        let shouldGroupByMonth = selectedPeriod == .sixMonths || selectedPeriod == .twelveMonths
//        let shouldGroupByMonth = false
        
        if shouldGroupByMonth {
            let groupedByMonth = Dictionary(grouping: sortedExpenses) { expense in
                Calendar.current.dateInterval(of: .month, for: expense.date)?.start ?? expense.date
            }
            
            for (monthStart, expenses) in groupedByMonth.sorted(by: { $0.key < $1.key }) {
                let monthTotal = expenses.reduce(0) { $0 + $1.amount }
                cumulative += monthTotal
                data.append(ChartDataPoint(date: monthStart, amount: monthTotal, cumulativeAmount: cumulative))
            }
        } else {
            for expense in sortedExpenses {
                cumulative += expense.amount
                data.append(ChartDataPoint(date: expense.date, amount: expense.amount, cumulativeAmount: cumulative))
            }
        }
        
        return data
    }
    
    private var incomeChartData: [ChartDataPoint] {
        let sortedIncome = filteredIncome.sorted { $0.date < $1.date }
        var cumulative = 0.0
        var data: [ChartDataPoint] = []
        
        let shouldGroupByMonth = selectedPeriod == .sixMonths || selectedPeriod == .twelveMonths
        
        if shouldGroupByMonth {
            let groupedByMonth = Dictionary(grouping: sortedIncome) { income in
                Calendar.current.dateInterval(of: .month, for: income.date)?.start ?? income.date
            }
            
            for (monthStart, incomes) in groupedByMonth.sorted(by: { $0.key < $1.key }) {
                let monthTotal = incomes.reduce(0) { $0 + $1.amount }
                cumulative += monthTotal
                data.append(ChartDataPoint(date: monthStart, amount: monthTotal, cumulativeAmount: cumulative))
            }
        } else {
            for income in sortedIncome {
                cumulative += income.amount
                data.append(ChartDataPoint(date: income.date, amount: income.amount, cumulativeAmount: cumulative))
            }
        }
        
        return data
    }
    
    private var categoryBreakdown: [CategoryData] {
        let categoryTotals = Dictionary(grouping: filteredExpenses, by: \.category)
            .mapValues { entries in entries.reduce(0) { $0 + $1.amount } }
            .filter { $0.value > 0 }
        
        return categoryTotals.map { CategoryData(category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    private func exportData(type: ExportType) {
        print("Exporting \(type)")
    }
}

// MARK: - Filters Section
struct FiltersSection: View {
    @Binding var selectedPeriod: ReportPeriod
    @Binding var showBusinessOnly: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(ReportPeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            HStack {
                Text("Business Miles Only")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: $showBusinessOnly)
            }
        }
        .padding()
        .background(AppTheme.lightGray)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

// MARK: - Animated Report Summary Cards
struct ReportSummaryCards: View {
    let expenseTotal: Double
    let incomeTotal: Double
    let mileageTotal: Double
    
    private var netIncome: Double {
        incomeTotal - expenseTotal
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            
            // Expenses Card
            AnimatedSummaryCard(
                title: "Total Expenses",
                value: expenseTotal,
                icon: "minus.circle.fill",
                color: .red,
                animationDelay: 0.1
            )
            .overlay(
                // Warning accent for high expenses
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1.5)
                    .opacity(expenseTotal > 5000 ? 1 : 0) // Show if expenses are significant
            )
            
            // Income Card
            AnimatedSummaryCard(
                title: "Total Income",
                value: incomeTotal,
                icon: "plus.circle.fill",
                color: AppTheme.accentGreen,
                animationDelay: 0.2
            )
            .overlay(
                // Success accent for income
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.accentGreen.opacity(0.4), lineWidth: 2)
                    .opacity(incomeTotal > 0 ? 1 : 0)
            )
            
            // Net Income Card - Special styling as most important metric
            AnimatedSummaryCard(
                title: "Net Income",
                value: netIncome,
                icon: netIncome >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis",
                color: netIncome >= 0 ? AppTheme.accentGreen : .red,
                animationDelay: 0.3
            )
            .background(
                // Dynamic background based on profit/loss
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(
                        (netIncome >= 0 ? AppTheme.accentGreen : Color.red)
                            .opacity(0.08)
                    )
            )
            .overlay(
                // Prominent border for net income
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                (netIncome >= 0 ? AppTheme.accentGreen : Color.red).opacity(0.6),
                                (netIncome >= 0 ? AppTheme.accentGreen : Color.red).opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            
            // Business Mileage Card
            AnimatedSummaryCard(
                title: "Business Mileage",
                value: mileageTotal,
                icon: "car.fill",
                color: .blue,
                isDistance: true,
                animationDelay: 0.4
            )
            .background(
                // Subtle blue tint for mileage
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(Color.blue.opacity(0.05))
            )
            .overlay(
                // Mileage achievement indicator
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(Color.blue.opacity(0.4), lineWidth: 1.5)
                    .opacity(mileageTotal > 1000 ? 1 : 0) // Show if mileage is significant
            )
        }
    }
}

// MARK: - Expenses Chart
struct ExpensesChart: View {
    let data: [ChartDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cumulative Expenses")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Chart(data) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Amount", item.cumulativeAmount)
                )
                .foregroundStyle(.red)
                .lineStyle(StrokeStyle(lineWidth: 3))
            }
            .frame(height: 200)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppTheme.lightGray)
            .cornerRadius(AppTheme.cornerRadius)
        }
    }
}

// MARK: - Income Chart
struct IncomeChart: View {
    let data: [ChartDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cumulative Income")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Chart(data) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Amount", item.cumulativeAmount)
                )
                .foregroundStyle(AppTheme.accentGreen)
                .lineStyle(StrokeStyle(lineWidth: 3))
            }
            .frame(height: 200)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppTheme.lightGray)
            .cornerRadius(AppTheme.cornerRadius)
        }
    }
}

// MARK: - Category Pie Chart
struct CategoryPieChart: View {
    let data: [CategoryData]
    let onViewBreakdown: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Text("Expense Categories")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
             
                Spacer()
                
                // In ReportsView, add this button:
                Button("📊 View Breakdown") {
                    onViewBreakdown()
                }
            }
            
            Chart(data) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.4),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("Category", item.category))
            }
            .frame(height: 250)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppTheme.lightGray)
            .cornerRadius(AppTheme.cornerRadius)
            
            // Category Legend
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(data.prefix(6)) { item in
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                        Text(item.category)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text("$\(String(format: "%.0f", item.amount))")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Supporting Data Structures
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let cumulativeAmount: Double
}

struct CategoryData: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

enum ExportType {
    case expenses, income, all
}
