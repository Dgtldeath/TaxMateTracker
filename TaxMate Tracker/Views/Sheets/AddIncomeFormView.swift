import SwiftUI
import SwiftData

struct AddIncomeFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var amount: String = ""
    @State private var businessName: String = ""
    @State private var selectedCategory = "Freelance Work"
    @State private var frequency = EntryFrequency.oneTime
    @State private var description: String = ""
    @State private var incomeDate = Date()
    
    // Income categories for self-employed/side work
    private let incomeCategories = [
        "Freelance Work",
        "Consulting Services",
        "Contract Work",
        "Gig Work (Uber/DoorDash/etc)",
        "Online Sales",
        "Creative Work (Design/Writing)",
        "Teaching/Tutoring",
        "Rental Income",
        "Commission Sales",
        "Affiliate Marketing",
        "Digital Products",
        "Other Income"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Income Details") {
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Date", selection: $incomeDate, displayedComponents: .date)
                    
                    TextField("Business/Client Name", text: $businessName)
                    
                    Picker("Income Type", selection: $selectedCategory) {
                        ForEach(incomeCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    Picker("Frequency", selection: $frequency) {
                        ForEach(EntryFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                }
                
                Section("Description") {
                    TextField("What was this income for?", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Projected Annual Income (for recurring income)
                if frequency != .oneTime {
                    Section("Projected Annual Income") {
                        if let amountValue = Double(amount), amountValue > 0 {
                            let annualIncome = calculateAnnualIncome(amount: amountValue, frequency: frequency)
                            Text("$\(String(format: "%.2f", annualIncome)) per year")
                                .foregroundColor(AppTheme.accentGreen)
                        }
                    }
                }
            }
            .navigationTitle("Add Side Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveIncomeEntry()
                    }
                    .disabled(amount.isEmpty || Double(amount) == nil || Double(amount)! <= 0)
                }
            }
        }
    }
    
    private func calculateAnnualIncome(amount: Double, frequency: EntryFrequency) -> Double {
        switch frequency {
        case .oneTime:
            return amount
        case .weekly:
            return amount * 52
        case .monthly:
            return amount * 12
        case .annually:
            return amount
        }
    }
    
    private func saveIncomeEntry() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        // Use businessName as description if description is empty
        let finalDescription = description.isEmpty ? businessName : description
        
        let incomeEntry = ExpenseEntry(
            amount: amountValue,
            date: incomeDate,
            category: selectedCategory,
            frequency: frequency,
            description: finalDescription,
            receiptImageData: nil,  // No receipts for income typically
            isIncome: true  // ✅ This is the key difference
        )
        
        modelContext.insert(incomeEntry)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save income entry: \(error)")
        }
    }
}