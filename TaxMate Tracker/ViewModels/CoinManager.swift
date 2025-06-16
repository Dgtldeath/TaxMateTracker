import Foundation

class CoinManager: ObservableObject {
    @Published var currentCoins: Int {
        didSet {
            UserDefaults.standard.set(currentCoins, forKey: "userCoins")
        }
    }
    
    private let startingCoins = 3
    
    init() {
        // Load coins from UserDefaults, default to 3 starting coins
        self.currentCoins = UserDefaults.standard.object(forKey: "userCoins") as? Int ?? startingCoins
        
        // If this is first launch, give starting coins
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            self.currentCoins = startingCoins
        }
    }
    
    func canAffordAnalysis() -> Bool {
        return currentCoins > 0
    }
    
    func spendCoin() -> Bool {
        guard canAffordAnalysis() else { return false }
        currentCoins -= 1
        return true
    }
    
    func addCoins(_ amount: Int) {
        currentCoins += amount
    }
    
    func resetCoins() {
        currentCoins = startingCoins
    }
}