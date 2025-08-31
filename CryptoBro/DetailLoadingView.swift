//
//  DetailLoadingView.swift
//  CryptoBro
//
//  Created by Sergey on 22.08.25.
//

import SwiftUI

struct DetailLoadingView: View {
    // This view only needs the ID of the coin to fetch
    let coinId: String
    
    // It will hold the fully-loaded coin once it's fetched
    @State private var coin: Coin? = nil
    
    private let networkManager = NetworkManager()
    
    var body: some View {
        ZStack {
            // If we have the coin data, show the real detail view
            if let coin = coin {
                CoinDetailView(coin: coin)
            } else {
                // Otherwise, show a loading spinner
                ProgressView()
            }
        }
        .task {
            // This task runs when the view appears, fetching the data
            do {
                self.coin = try await networkManager.fetchCoinDetails(coinId: coinId)
            } catch {
                print("Error fetching coin details: \(error)")
                // You could add error handling here, like showing an alert
            }
        }
    }
}
