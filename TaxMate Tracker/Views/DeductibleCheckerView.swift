//
//  DeductibleCheckerView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 6/14/25.
//

import SwiftUI

struct DeductibleCheckerView: View {
    let expense: ExpenseEntry
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var coinManager = CoinManager()
    @StateObject private var storeManager: StoreManager
    @StateObject private var apiService: DeductibleAPIService
    
    @State private var showingCoinStore = false
    @State private var showingOutOfCoinsAlert = false
    @State private var showingReceiptImage = false
    
    init(expense: ExpenseEntry) {
        self.expense = expense
        
        let coinManager = CoinManager()
        self._coinManager = StateObject(wrappedValue: coinManager)
        self._storeManager = StateObject(wrappedValue: StoreManager(coinManager: coinManager))
        self._apiService = StateObject(wrappedValue: DeductibleAPIService(coinManager: coinManager))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Coin Balance Card
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(coinManager.currentCoins) coins")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button("Get More") {
                            showingCoinStore = true
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.accentGreen)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    }
                    .padding()
                    .background(AppTheme.lightGray)
                    .cornerRadius(8)
                    
                    // ✅ Item Details Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Item Details")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(label: "Amount", value: "$\(String(format: "%.2f", expense.amount))")
                            DetailRow(label: "Category", value: expense.category)
                            DetailRow(label: "Date", value: expense.date.formatted(date: .abbreviated, time: .omitted))
                            DetailRow(label: "Frequency", value: expense.frequency.rawValue)
                            
                            if !expense.entryDescription.isEmpty {
                                DetailRow(label: "Description", value: expense.entryDescription)
                            }
                            
                            DetailRow(label: "Type", value: expense.isIncome ? "Income" : "Expense")
                        }
                    }
                    .padding()
                    .background(AppTheme.lightGray)
                    .cornerRadius(AppTheme.cornerRadius)
                    
                    // ✅ Receipt Photo Section
                    if let receiptData = expense.receiptImageData,
                       let receiptImage = UIImage(data: receiptData) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Receipt Photo")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Button(action: {
                                showingReceiptImage = true
                            }) {
                                Image(uiImage: receiptImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 120)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            Text("Tap to view full size")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(AppTheme.lightGray)
                        .cornerRadius(AppTheme.cornerRadius)
                    }
                    
                    // ✅ AI Analysis Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("✨ AI Tax Analysis")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding([.top, .horizontal])
                        
                        if apiService.isLoading {
                            VStack(spacing: 16) {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Analyzing with AI...")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text("Checking IRS regulations and tax code")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            
                        } else if !apiService.errorMessage.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                                
                                Text("Analysis Failed")
                                    .font(.headline)
                                
                                Text(apiService.errorMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Try Again") {
                                    checkCoinsAndAnalyze()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppTheme.accentGreen)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            
                        } else if !apiService.response.isEmpty || !expense.aiAnalysis.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(AppTheme.accentGreen)
                                    Text("Analysis Complete")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                
                                Text(apiService.response.isEmpty ? expense.aiAnalysis : apiService.response)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding(.top, 4)
                                
                                HStack {
                                    Spacer()
                                    Button("✨ Analyze Again (1 Coin)") {
                                        checkCoinsAndAnalyze()
                                    }
                                    .font(.caption)
                                    .foregroundColor(AppTheme.accentGreen)
                                }
                                .padding(.top, 8)
                            }
                            .padding()
                            
                        } else {
                            // ✅ Manual AI Analysis Button - No Auto-Trigger
                            VStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(AppTheme.accentGreen)
                                    .font(.title2)
                                
                                Text("Get AI Tax Analysis")
                                    .font(.headline)
                                
                                Text("Ask our AI if this expense is tax deductible")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("✨ Ask AI (Costs 1 Coin)") {
                                    checkCoinsAndAnalyze()
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.accentGreen)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .disabled(coinManager.currentCoins == 0)
                                
                                if coinManager.currentCoins == 0 {
                                    Text("Out of coins - Purchase more to continue")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.lightGray)
                    .cornerRadius(AppTheme.cornerRadius)
                }
                .padding()
            }
            .navigationTitle("Item Details") // ✅ Changed title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCoinStore) {
                CoinStoreView(storeManager: storeManager, coinManager: coinManager)
            }
            .sheet(isPresented: $showingReceiptImage) {
                if let receiptData = expense.receiptImageData,
                   let receiptImage = UIImage(data: receiptData) {
                    FullScreenImageView(image: receiptImage)
                }
            }
            .alert("Out of Coins", isPresented: $showingOutOfCoinsAlert) {
                Button("Buy Coins") {
                    showingCoinStore = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You need coins to get AI tax analysis. Would you like to purchase more?")
            }
        }
        .onAppear {
            // ✅ Load existing analysis if available (no auto-trigger)
            if !expense.aiAnalysis.isEmpty {
                apiService.response = expense.aiAnalysis
            }
        }
    }
    
    private func checkCoinsAndAnalyze() {
        if coinManager.canAffordAnalysis() {
            Task {
                let result = await apiService.checkIfDeductible(expense: expense)
                
                if result.success && result.coinSpent {
                    await saveAnalysisToDatabase(message: result.message)
                }
            }
        } else {
            showingOutOfCoinsAlert = true
        }
    }
    
    @MainActor
    private func saveAnalysisToDatabase(message: String) async {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        let analysisWithTimestamp = "✨ AI Analysis (\(timestamp)):\n\(message)"
        
        if !expense.aiAnalysis.isEmpty {
            expense.aiAnalysis += "\n\n" + analysisWithTimestamp
        } else {
            expense.aiAnalysis = analysisWithTimestamp
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save AI analysis: \(error)")
        }
    }
}

// ✅ Helper Views
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct FullScreenImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            .navigationTitle("Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}
