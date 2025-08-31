//
//  Coin.swift
//  CryptoBro
//
//  Created by Sergey on 22.08.25.
//
import Foundation

// The updated blueprint with more details
struct Coin: Identifiable, Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double?
    let marketCapRank: Int?
    let totalVolume: Double?
    let high24h: Double?
    let low24h: Double?
    let priceChangePercentage24h: Double?
    let priceChange24h: Double?

    // Update the 'translator' to include the new properties
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case totalVolume = "total_volume"
        case high24h = "high_24h"
        case low24h = "low_24h"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case priceChange24h = "price_change_24h"

    }
}

