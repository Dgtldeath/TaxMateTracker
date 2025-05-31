//
//  Item.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
