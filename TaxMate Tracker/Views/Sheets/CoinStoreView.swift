//
//  CoinStoreView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 6/16/25.
//

import SwiftUI

struct CoinStoreView: View {
    @ObservedObject var storeManager: StoreManager
    @ObservedObject var coinManager: CoinManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Current Balance
                VStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.yellow)
                        .font(.largeTitle)
                    
                    Text("Current Balance")
                        .font(.headline)
                    
                    Text("\(coinManager.currentCoins) coins")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                // Coin Package
                if let product = storeManager.products.first {
                    VStack(spacing: 16) {
                        VStack {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(AppTheme.accentGreen)
                                Text("15 AI Analysis Coins")
                                    .font(.headline)
                            }
                            
                            Text("Get detailed tax deductibility analysis for your expenses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            Task {
                                await storeManager.purchaseCoins()
                            }
                        }) {
                            HStack {
                                if storeManager.isPurchasing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text(storeManager.isPurchasing ? "Processing..." : "Purchase for \(product.displayPrice)")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(storeManager.isPurchasing ? Color.gray : AppTheme.accentGreen)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .disabled(storeManager.isPurchasing)
                    }
                    .padding()
                    .background(AppTheme.lightGray)
                    .cornerRadius(12)
                } else {
                    VStack {
                        ProgressView()
                        Text("Loading products...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                // Restore button
//                Button("Restore Purchases") {
//                    Task {
//                        await storeManager.restorePurchases()
//                    }
//                }
//                .font(.subheadline)
//                .foregroundColor(AppTheme.accentGreen)
                
                // Professional disclaimer
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Professional Advice Recommended")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Text("AI analysis is for informational purposes only. Consult a qualified tax professional for official advice.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("✨ Get More Coins")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $storeManager.hasError) {
            Button("OK") { }
        } message: {
            Text(storeManager.errorMessage)
        }
        .task {
            await storeManager.loadProducts()
        }
    }
}
