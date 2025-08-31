//
//  CreditManager.swift
//  CryptoBro
//
//  Created by Sergey on 23.08.25.
//

import Foundation

class CreditManager: ObservableObject {
    static let shared = CreditManager()
    
    @Published private(set) var coinBalance: Int // Use @Published to update the UI automatically
    
    private let userDefaultsKey = "userCoinBalance"
    
    private init() {
        // Load the balance from storage, or give the user 100 coins if it's their first time.
        self.coinBalance = UserDefaults.standard.integer(forKey: userDefaultsKey)
        if UserDefaults.standard.object(forKey: userDefaultsKey) == nil {
            self.coinBalance = 100
        }
    }
    
    // Tries to spend coins. Returns true if successful, false otherwise.
    func spendCoins(amount: Int) -> Bool {
        guard coinBalance >= amount else {
            print("Not enough coins!")
            return false // Transaction failed
        }
        
        coinBalance -= amount
        saveBalance()
        print("\(amount) coins spent. New balance: \(coinBalance)")
        return true // Transaction successful
    }
    
    // Adds coins to the balance (e.g., for a daily reward or reset).
    func addCoins(amount: Int) {
        coinBalance += amount
        saveBalance()
        print("\(amount) coins added. New balance: \(coinBalance)")
    }
    
    // Saves the current balance to the device's storage.
    private func saveBalance() {
        UserDefaults.standard.set(coinBalance, forKey: userDefaultsKey)
    }
}
