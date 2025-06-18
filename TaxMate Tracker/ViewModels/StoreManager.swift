//
//  StoreManager.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 6/16/25.
//


import Foundation
import StoreKit


@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var hasError = false
    @Published var errorTitle = ""
    @Published var errorMessage = ""
    @Published var isPurchasing = false
    
    private let coinManager: CoinManager
    
    // Product identifier for 15 coins at $0.99
    private let coinProductID = APIConfig.storeProductID
    
    init(coinManager: CoinManager) {
        self.coinManager = coinManager
        
        Task {
            await loadProducts()
        }
    }
    
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [coinProductID])
            self.products = products
        } catch {
            showError(title: "Products Failed to Load", message: error.localizedDescription)
        }
    }
    
    func purchaseCoins() async {
        guard let product = products.first else {
            showError(title: "Product Not Found", message: "Unable to find coin package.")
            return
        }
        
        isPurchasing = true
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                // Award coins for successful purchase
                coinManager.addCoins(15)
                
                // Mark transaction as finished
                await transaction.finish()
                
                isPurchasing = false
                
            case .userCancelled:
                isPurchasing = false
                
            case .pending:
                isPurchasing = false
                showError(title: "Purchase Pending", message: "Your purchase is pending approval.")
                
            @unknown default:
                isPurchasing = false
                showError(title: "Unknown Result", message: "An unknown purchase result occurred.")
            }
        } catch {
            isPurchasing = false
            showError(title: "Purchase Failed", message: error.localizedDescription)
        }
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            
            // Check for any unfinished transactions
            for await result in Transaction.currentEntitlements {
                do {
                    let transaction = try checkVerified(result)
                    
                    // Handle any consumable purchases that weren't processed
                    if transaction.productID == coinProductID {
                        // Award coins if needed
                        await transaction.finish()
                    }
                } catch {
                    print("Failed to process transaction: \(error)")
                }
            }
        } catch {
            showError(title: "Restore Failed", message: error.localizedDescription)
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func showError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        hasError = true
    }
}

enum StoreError: Error {
    case failedVerification
}
