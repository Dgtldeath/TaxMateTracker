import Foundation

class DeductibleAPIService: ObservableObject {
    @Published var isLoading = false
    @Published var response = ""
    @Published var errorMessage = ""
    
    func checkIfDeductible(expense: ExpenseEntry) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.response = ""
            self.errorMessage = ""
        }
        
        guard let url = URL(string: "https://mydomain.com/ai-api/gpt.php") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }
        
        // Prepare the request data
        let requestData: [String: Any] = [
            "amount": expense.amount,
            "category": expense.category,
            "description": expense.entryDescription,
            "date": ISO8601DateFormatter().string(from: expense.date),
            "frequency": expense.frequency.rawValue,
            "query": "Is this expense tax deductible for a self-employed individual? Please provide a detailed explanation."
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                if let responseString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.response = responseString
                        self.isLoading = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Server error"
                    self.isLoading = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}