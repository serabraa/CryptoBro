//
//  SetAlertView.swift
//  CryptoBro
//
//  Created by Sergey on 31.08.25.
//

import SwiftUI

struct SetAlertView: View {
    @Environment(\.dismiss) var dismiss
    
    let coin: Coin
    
    @State private var targetPriceString = ""
    @State private var selectedDirection: AlertDirection = .above
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Coin")) {
                    Text(coin.name)
                }
                
                Section(header: Text("Condition")) {
                    Picker("Notify me when price is", selection: $selectedDirection) {
                        Text(AlertDirection.above.rawValue).tag(AlertDirection.above)
                        Text(AlertDirection.below.rawValue).tag(AlertDirection.below)
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Target Price (USD)", text: $targetPriceString)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Set Alert")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // In SetAlertView.swift
                    Button("Save") {
                        // 1. Create a formatter that understands local number styles
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        formatter.locale = .current // IMPORTANT: Use the user's current device settings

                        // 2. Use the formatter to convert the string to a number
                        if let number = formatter.number(from: targetPriceString) {
                            let targetPrice = number.doubleValue // Get the Double value
                            
                            // 3. The rest of your saving logic is the same
                            let newAlert = PriceAlert(id: coin.id,
                                                      coinSymbol: coin.symbol,
                                                      targetPrice: targetPrice,
                                                      direction: selectedDirection)
                            
                            AlertPersistenceManager.shared.save(alert: newAlert)
                            dismiss()
                        } else {
                            // This will happen if the user types invalid text
                            print("Invalid number format entered.")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
