//
//  UserProfile.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//

import Foundation
import SwiftData


@Model
final class UserProfile {
    var id = UUID()
    var name: String
    var businessName: String
    var subscriptionTier: SubscriptionTier
    var notificationsEnabled: Bool
    var createdDate: Date
    
    init(name: String = "", businessName: String = "", subscriptionTier: SubscriptionTier = .free) {
        self.name = name
        self.businessName = businessName
        self.subscriptionTier = subscriptionTier
        self.notificationsEnabled = true
        self.createdDate = Date()
    }
}
