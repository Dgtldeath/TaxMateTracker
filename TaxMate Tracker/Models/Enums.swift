//
//  Enums.swift
//  TaxMate Tracker
//
//  Created by Adam Gumm on 5/30/25.
//



// MARK: - Enums
enum EntryFrequency: String, CaseIterable, Codable {
    case oneTime = "One-time"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case annually = "Annually"
}

enum SubscriptionTier: String, CaseIterable, Codable {
    case free = "Free"
    case premium = "Premium"
}

enum ReportPeriod: String, CaseIterable {
    case oneMonth = "1 Month"
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"
    case twelveMonths = "12 Months"
}

enum TripPurpose: String, CaseIterable, Codable {
    case clientMeeting = "Client Meeting"
    case delivery = "Delivery"
    case businessTravel = "Business Travel"
    case supplies = "Getting Supplies"
    case bankBusiness = "Bank/Business Errands"
    case networking = "Networking Event"
    case other = "Other Business"
}
