import Foundation
import StoreKit

class StoreManager: NSObject, ObservableObject {
    @Published var products: [SKProduct] = []
    @Published var transactionState: SKPaymentTransactionState?
    @Published var hasError = false
    @Published var errorTitle = ""
    @Published var errorMessage = ""
    
    private let coinManager: CoinManager
    
    // Product identifier for 15 coins at $0.99
    private let coinProductID = "com.yourapp.taxmate.coins15"
    
    init(coinManager: CoinManager) {
        self.coinManager = coinManager
        super.init()
        SKPaymentQueue.default().add(self)
        getProducts()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func getProducts() {
        guard !coinProductID.isEmpty else { return }
        
        let request = SKProductsRequest(productIdentifiers: Set([coinProductID]))
        request.delegate = self
        request.start()
    }
    
    func purchaseCoins() {
        guard let product = products.first else {
            showError(title: "Product Not Found", message: "Unable to find coin package.")
            return
        }
        
        guard SKPaymentQueue.canMakePayments() else {
            showError(title: "Purchases Disabled", message: "In-app purchases are disabled on this device.")
            return
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    private func showError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        hasError = true
    }
}

// MARK: - SKProductsRequestDelegate
extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
                
            case .purchased:
                queue.finishTransaction(transaction)
                transactionState = .purchased
                
                // Award 15 coins for successful purchase
                coinManager.addCoins(15)
                
            case .restored:
                queue.finishTransaction(transaction)
                transactionState = .restored
                
            case .failed:
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
                        showError(title: "Purchase Failed", message: error.localizedDescription)
                    }
                }
                queue.finishTransaction(transaction)
                transactionState = .failed
                
            case .deferred:
                transactionState = .deferred
                
            @unknown default:
                break
            }
        }
    }
}