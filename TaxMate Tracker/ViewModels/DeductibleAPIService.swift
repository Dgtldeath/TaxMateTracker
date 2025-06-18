//
//  DeductibleAPIService.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 6/14/25.
//

import Foundation
import SwiftData

// ✅ Result struct for API response
struct AIAnalysisResult {
    let success: Bool
    let message: String
    let coinSpent: Bool
}

class DeductibleAPIService: ObservableObject {
    @Published var isLoading = false
    @Published var response = ""
    @Published var errorMessage = ""
    
    private let coinManager: CoinManager
    
    init(coinManager: CoinManager) {
        self.coinManager = coinManager
    }
    
    func checkIfDeductible(expense: ExpenseEntry) async -> AIAnalysisResult {
        // Extract data from expense BEFORE async operations
        let existingAnalysis = expense.aiAnalysis
        let expenseAmount = expense.amount
        let expenseCategory = expense.category
        let expenseDescription = expense.entryDescription
        let expenseDate = expense.date
        let expenseFrequency = expense.frequency
        
        // Check if user has existing analysis
        if !existingAnalysis.isEmpty {
            await MainActor.run {
                self.response = existingAnalysis
                self.isLoading = false
            }
            return AIAnalysisResult(success: true, message: existingAnalysis, coinSpent: false)
        }
        
        await MainActor.run {
            self.isLoading = true
            self.response = ""
            self.errorMessage = ""
        }
        
        guard let url = URL(string: APIConfig.aiAPIURL) else {
            let error = "Invalid API URL configuration"
            await MainActor.run {
                self.errorMessage = error
                self.isLoading = false
            }
            return AIAnalysisResult(success: false, message: error, coinSpent: false)
        }
        
        let requestData: [String: Any] = [
            "app": APIConfig.appSlug,
            "modelType": APIConfig.defaultModelType,
            "expenseData": [
                "amount": expenseAmount,
                "category": expenseCategory,
                "description": expenseDescription,
                "date": ISO8601DateFormatter().string(from: expenseDate),
                "frequency": expenseFrequency.rawValue
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.timeoutInterval = APIConfig.requestTimeout
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let messageText = jsonResponse["response"] as? String {
                        
                        // Spend coin only on successful analysis
                        let coinSpent = coinManager.spendCoin()
                        
                        if coinSpent {
                            await MainActor.run {
                                self.response = messageText
                                self.isLoading = false
                            }
                            return AIAnalysisResult(success: true, message: messageText, coinSpent: true)
                        } else {
                            let error = "Unable to spend coin. Please try again."
                            await MainActor.run {
                                self.errorMessage = error
                                self.isLoading = false
                            }
                            return AIAnalysisResult(success: false, message: error, coinSpent: false)
                        }
                    } else {
                        let error = "Invalid response format from server"
                        await MainActor.run {
                            self.errorMessage = error
                            self.isLoading = false
                        }
                        return AIAnalysisResult(success: false, message: error, coinSpent: false)
                    }
                } else {
                    let error = "Server error (Code: \(httpResponse.statusCode))"
                    await MainActor.run {
                        self.errorMessage = error
                        self.isLoading = false
                    }
                    return AIAnalysisResult(success: false, message: error, coinSpent: false)
                }
            }
        } catch {
            let errorMsg = "Network error: \(error.localizedDescription)"
            await MainActor.run {
                self.errorMessage = errorMsg
                self.isLoading = false
            }
            return AIAnalysisResult(success: false, message: errorMsg, coinSpent: false)
        }
        
        let error = "Unknown error occurred"
        await MainActor.run {
            self.errorMessage = error
            self.isLoading = false
        }
        return AIAnalysisResult(success: false, message: error, coinSpent: false)
    }
}
