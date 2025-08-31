//
//  PriceCheckService.swift
//  CryptoBro
//
//  Created by Sergey on 31.08.25.
//

import Foundation

class PriceCheckService {
    static let shared = PriceCheckService()
    private let persistence = AlertPersistenceManager.shared

    // In PriceCheckService.swift, replace the entire checkPrices function
    func checkPrices() async {
        let alertsToCheck = persistence.alerts
        let alertCoinIds = Set(alertsToCheck.map { $0.id }) // Use a Set for efficient filtering
        
        print(" BACKGROUND CHECK: Starting price check for \(alertCoinIds.count) active alerts...")
        
        guard !alertCoinIds.isEmpty else { return }
        
        do {
            let networkManager = NetworkManager()
            // 1. Fetch the top coins, a call we know is reliable.
            let allCoins = try await networkManager.fetchCoins()
            print(" BACKGROUND CHECK: Successfully fetched top coins.")

            // 2. Filter this large list to find only the coins we have alerts for.
            let relevantCoins = allCoins.filter { alertCoinIds.contains($0.id) }
            print(" BACKGROUND CHECK: Found \(relevantCoins.count) relevant coins to check.")
            
            for coin in relevantCoins {
                if let alert = alertsToCheck.first(where: { $0.id == coin.id }) {
                    
                    print("   - Checking \(alert.coinSymbol): Current is \(coin.currentPrice.formatted(.currency(code: "usd"))), Target is \(alert.direction.rawValue) \(alert.targetPrice.formatted(.currency(code: "usd")))")
                    
                    var conditionMet = false
                    switch alert.direction {
                    case .above:
                        if coin.currentPrice >= alert.targetPrice { conditionMet = true }
                    case .below:
                        if coin.currentPrice <= alert.targetPrice { conditionMet = true }
                    }
                    
                    // In PriceCheckService.swift, inside the for-loop
                    if conditionMet {
                        print("     ✅ CONDITION MET! Switching to main thread to notify and delete.")
                        
                        // Switch to the main thread before scheduling notifications or changing published data
                        await MainActor.run {
                            NotificationManager.shared.schedulePriceAlertNotification(
                                symbol: alert.coinSymbol,
                                price: coin.currentPrice,
//                                direction: alert.direction
                            )
                            // Now that we're on the main thread, this is safe to call
                            persistence.delete(for: alert.id)
                        }
                    } else {
                        print("     ❌ Condition NOT met.")
                    }
                }
            }
            print(" BACKGROUND CHECK: Price check finished.")
        } catch {
            print(" BACKGROUND CHECK: Failed during price check: \(error)")
        }
    }
}
