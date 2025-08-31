//
//  APIConstants.swift
//  CryptoBro
//
//  Created by Sergey on 22.08.25.
//

import Foundation

struct APIConstants {
    // Safely reads a key from the project's Info.plist
    private static func apiKey(named keyName: String) -> String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: keyName) as? String else {
            fatalError("\(keyName) not found in Info.plist. Please set it up.")
        }
        return apiKey
    }

    // Public properties to access the keys throughout the app
    static let coinGeckoApiKey = apiKey(named: "CoinGeckoApiKey")
    static let openAIKey = apiKey(named: "OpenAiApiKey")
    static let cryptoPanicApiKey = apiKey(named: "CryptoPanicApiKey")

    // Your existing base URL
    static let proBaseURL = "https://api.coingecko.com/api/v3"
}
