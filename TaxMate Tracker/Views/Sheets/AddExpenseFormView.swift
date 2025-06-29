//
//  AddExpenseFormView.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 6/6/25.
//


import SwiftUI
import SwiftData

struct AddExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var amount: String = ""
    @State private var selectedCategory = "Office Supplies & Expenses"
    @State private var frequency = EntryFrequency.oneTime
    @State private var description: String = ""
    @State private var expenseDate = Date()
    @State private var showingImagePicker = false
    @State private var receiptImage: UIImage?
    @State private var imageSourceType: UIImagePickerController.SourceType = .camera
    
    // Default expense categories
    private let expenseCategories = [
        "Advertising & Marketing",
        "Commissions & Fees",
        "Office Supplies & Expenses",
        "Software & Subscriptions",
        "Travel & Meals",
        "Vehicle & Mileage",
        "Legal & Professional Services",
        "Utilities & Phone (Business Use)",
        "Education & Training",
        "Insurance & Licenses",
        "Repairs & Maintenance",
        "Other Deductible Expenses"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Expense Details") {
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Date", selection: $expenseDate, displayedComponents: .date)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(expenseCategories, id: \.self) { category in
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
                    TextField("What was this expense for?", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Receipt") {
                    if let receiptImage = receiptImage {
                        HStack {
                            Image(uiImage: receiptImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading) {
                                Text("Receipt attached")
                                    .font(.subheadline)
                                Button("Change Photo") {
                                    imageSourceType = .camera
                                    showingImagePicker = true
                                }
                                .font(.caption)
                                .foregroundColor(AppTheme.accentGreen)
                            }
                            
                            Spacer()
                            
                            Button("Remove") {
                                self.receiptImage = nil
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    } else {
                        VStack(spacing: 12) {
                            // Camera Button
                            Button(action: {
                                imageSourceType = .camera
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { // ✅ Small delay
                                    showingImagePicker = true
                                    print("camera")
                                }
                            }) {
                                HStack {
                                    Image(systemName: "camera")
                                    Text("Take Receipt Photo")
                                }
                                .foregroundColor(AppTheme.accentGreen)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(AppTheme.accentGreen.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle()) // ✅ Fix button style
                            
                            // Photo Library Button
                            Button(action: {
                                imageSourceType = .photoLibrary
                                showingImagePicker = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { // ✅ Small delay
                                    showingImagePicker = true
                                    print("photo library")
                                }
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text("Choose from Photo Library")
                                }
                                .foregroundColor(AppTheme.accentGreen)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(AppTheme.accentGreen.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle()) // ✅ Fix button style
                        }
                    }
                }
                
                // Projected Annual Cost (for recurring expenses)
                if frequency != .oneTime {
                    Section("Projected Annual Cost") {
                        if let amountValue = Double(amount), amountValue > 0 {
                            let annualCost = calculateAnnualCost(amount: amountValue, frequency: frequency)
                            Text("$\(String(format: "%.2f", annualCost)) per year")
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExpenseEntry()
                    }
                    .disabled(amount.isEmpty || Double(amount) == nil || Double(amount)! <= 0)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $receiptImage, sourceType: imageSourceType)
            }
        }
    }
    
    private func calculateAnnualCost(amount: Double, frequency: EntryFrequency) -> Double {
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
    
    private func saveExpenseEntry() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        let receiptData = receiptImage?.jpegData(compressionQuality: 0.8)
        
        let expenseEntry = ExpenseEntry(
            amount: amountValue,
            date: expenseDate,
            category: selectedCategory,
            frequency: frequency,
            description: description,
            receiptImageData: receiptData,
            isIncome: false
        )
        
        modelContext.insert(expenseEntry)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save expense entry: \(error)")
        }
    }
}
