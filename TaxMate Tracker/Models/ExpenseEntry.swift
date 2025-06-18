//
//  ExpenseEntry.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import Foundation
import SwiftData

@Model
final class ExpenseEntry {
    var id = UUID()
    var amount: Double
    var date: Date
    var category: String
    var frequency: EntryFrequency
    var entryDescription: String
    var receiptImageData: Data?
    var isIncome: Bool
    var aiAnalysis: String = ""
    
    init(amount: Double, date: Date, category: String, frequency: EntryFrequency, description: String, receiptImageData: Data? = nil, isIncome: Bool = false, aiAnalysis: String = "") {
        self.amount = amount
        self.date = date
        self.category = category
        self.frequency = frequency
        self.entryDescription = description
        self.receiptImageData = receiptImageData
        self.isIncome = isIncome
    }
}
