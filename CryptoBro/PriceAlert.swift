//
//  PriceAlert.swift
//  CryptoBro
//
//  Created by Sergey on 30.08.25.
//

import Foundation

// An enum to safely represent the two possible directions for an alert
enum AlertDirection: String, Codable {
    case above = "Above"
    case below = "Below"
}

struct PriceAlert: Identifiable, Codable {
    let id: String // The coin's ID, e.g., "bitcoin"
    let coinSymbol: String
    let targetPrice: Double
    let direction: AlertDirection // <-- ADD THIS
}
