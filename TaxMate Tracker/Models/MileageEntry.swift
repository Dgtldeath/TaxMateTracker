//
//  MileageEntry.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import Foundation
import SwiftData

@Model
final class MileageEntry {
    var id = UUID()
    var startDate: Date
    var endDate: Date?
    var distance: Double
    var startLocation: String
    var endLocation: String
    var purpose: String
    var notes: String
    var isBusinessTrip: Bool
    
    init(startDate: Date, distance: Double = 0, startLocation: String = "", endLocation: String = "", purpose: String = "", notes: String = "", isBusinessTrip: Bool = true) {
        self.startDate = startDate
        self.distance = distance
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.purpose = purpose
        self.notes = notes
        self.isBusinessTrip = isBusinessTrip
    }
}
