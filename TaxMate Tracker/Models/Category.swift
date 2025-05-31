//
//  Category.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import Foundation
import SwiftData

@Model
final class Category {
    var id = UUID()
    var name: String
    var color: String
    var isExpense: Bool
    var isDefault: Bool
    
    init(name: String, color: String = "blue", isExpense: Bool = true, isDefault: Bool = false) {
        self.name = name
        self.color = color
        self.isExpense = isExpense
        self.isDefault = isDefault
    }
}
