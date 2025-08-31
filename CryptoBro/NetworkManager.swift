//
//  NetworkManager.swift
//  CryptoBro
//
//  Created by Sergey on 22.08.25.
//

import Foundation

class NetworkManager {
    
    // Updated to use the Pro API with your key
    // In NetworkManager.swift, replace the main fetchCoins() function
    func fetchCoins() async throws -> [Coin] {
        
        print("🔑 DEBUG: Attempting to use CoinGecko API Key: '\(APIConstants.coinGeckoApiKey)'")
        
        let endpoint = "\(APIConstants.proBaseURL)/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=false&x_cg_demo_api_key=\(APIConstants.coinGeckoApiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // First, check for a successful HTTP status code (200 OK).
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
            // If the status is not 200, throw a specific error.
            throw NSError(domain: "CoinGeckoAPI", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "API request for top coins failed with status code: \(statusCode). Check your API Key."])
        }
        
        // Only if the status is OK, do we try to decode the array of coins.
        do {
            return try JSONDecoder().decode([Coin].self, from: data)
        } catch {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("--- RAW JSON RESPONSE THAT FAILED TO DECODE ---\n\(jsonString)\n--------------------")
            }
            throw error
        }
    }

    // Updated to use the Pro API with your key
    func searchCoins(query: String) async throws -> [SearchResultCoin] {
        let endpoint = "\(APIConstants.proBaseURL)/search?query=\(query)&x_cg_demo_api_key=\(APIConstants.coinGeckoApiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
        return response.coins
    }

    // Updated to use the Pro API with your key
    func fetchCoinDetails(coinId: String) async throws -> Coin? {
        let endpoint = "\(APIConstants.proBaseURL)/coins/markets?vs_currency=usd&ids=\(coinId)&sparkline=false&x_cg_demo_api_key=\(APIConstants.coinGeckoApiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let coins = try JSONDecoder().decode([Coin].self, from: data)
        return coins.first
    }
    

    // Add this new function inside your NetworkManager 
    func fetchNews(for coinSymbol: String) async throws -> [NewsPost] {
        // --- THIS IS THE DEFINITIVELY CORRECTED ENDPOINT ---
        let endpoint = "https://cryptopanic.com/api/developer/v2/posts/?auth_token=\(APIConstants.cryptoPanicApiKey)&currencies=\(coinSymbol)&kind=news"
        
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
            throw NSError(domain: "CryptoPanicAPI", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "API request failed with status code: \(statusCode)."])
        }
        
        do {
            let apiResponse = try JSONDecoder().decode(CryptoPanicResponse.self, from: data)
            return apiResponse.results
        } catch {
            print("Failed to decode CryptoPanic JSON: \(error)")
            throw error
        }
    }
    
    // In NetworkManager.swift
    // In NetworkManager.swift, replace the fetchCoins(ids:) function
    func fetchCoins(ids: [String]) async throws -> [Coin] {
        // Don't make an API call if there are no IDs to fetch
        guard !ids.isEmpty else { return [] }
        
        let idsString = ids.joined(separator: ",")
        let endpoint = "\(APIConstants.proBaseURL)/coins/markets?vs_currency=usd&ids=\(idsString)&x_cg_demo_api_key=\(APIConstants.coinGeckoApiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // First, check for a successful HTTP status code (200 OK).
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
            // If the status is not 200, throw a specific error.
            throw NSError(domain: "CoinGeckoAPI", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "API request for coin IDs failed with status code: \(statusCode)."])
        }
        
        // Only if the status is OK, do we try to decode the array of coins.
        do {
            return try JSONDecoder().decode([Coin].self, from: data)
        } catch {
            // This is a great debugging tool: if decoding fails, print the raw text from the server.
            if let jsonString = String(data: data, encoding: .utf8) {
                print("--- RAW JSON RESPONSE THAT FAILED TO DECODE ---\n\(jsonString)\n--------------------")
            }
            throw error
        }
    }
}
