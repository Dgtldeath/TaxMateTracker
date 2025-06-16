struct DeductibleCheckerView: View {
    let expense: ExpenseEntry
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiService = DeductibleAPIService()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Expense Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Checking Expense")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Amount:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("$\(String(format: "%.2f", expense.amount))")
                            }
                            
                            HStack {
                                Text("Category:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(expense.category)
                            }
                            
                            if !expense.entryDescription.isEmpty {
                                HStack {
                                    Text("Description:")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(expense.entryDescription)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            
                            HStack {
                                Text("Date:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(expense.date, style: .date)
                            }
                        }
                        .font(.subheadline)
                    }
                    .padding()
                    .background(AppTheme.lightGray)
                    .cornerRadius(AppTheme.cornerRadius)
                    
                    // API Response
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Deductibility Analysis")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        if apiService.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Analyzing expense...")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding()
                        } else if !apiService.errorMessage.isEmpty {
                            Text(apiService.errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .padding()
                        } else if !apiService.response.isEmpty {
                            ScrollView {
                                Text(apiService.response)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .padding()
                            }
                            .frame(maxHeight: 300)
                        } else {
                            Text("Tap 'Check Deductibility' to get AI analysis")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                .padding()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.lightGray)
                    .cornerRadius(AppTheme.cornerRadius)
                    
                    // Check Button
                    if !apiService.isLoading && apiService.response.isEmpty {
                        Button("Check Deductibility") {
                            Task {
                                await apiService.checkIfDeductible(expense: expense)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.accentGreen)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Tax Deductible?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Auto-check when view appears
            if apiService.response.isEmpty && !apiService.isLoading {
                Task {
                    await apiService.checkIfDeductible(expense: expense)
                }
            }
        }
    }
}