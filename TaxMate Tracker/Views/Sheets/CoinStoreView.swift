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
                            storeManager.purchaseCoins()
                        }) {
                            Text("Purchase for \(product.localizedPrice ?? "$0.99")")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.accentGreen)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(storeManager.transactionState == .purchasing)
                    }
                    .padding()
                    .background(AppTheme.lightGray)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Get More Coins")
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
    }
}

extension SKProduct {
    var localizedPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)
    }
}