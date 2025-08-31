//
//  CoinDetailView.swift
//  CryptoBro
//
//  Created by Sergey on 22.08.25.
//
import SwiftUI

struct CoinDetailView: View {
    // MARK: - PROPERTIES
    let coin: Coin
    
    // State variables for the AI feature
    @State private var predictionStatus: String? = nil
    @State private var predictionExplanation: String? = nil
    @State private var isLoadingAI = false
    
    // At the top of CoinDetailView
    @ObservedObject private var creditManager = CreditManager.shared
    @State private var showNotEnoughCoinsAlert = false // To show a pop-up
    
    @State private var newsPosts: [NewsPost] = [] // <-- ADD THIS
    private let networkManager = NetworkManager()
    
    @State private var isAnalysisSaved = false
    
    //related to the alerts
    @ObservedObject private var alertManager = AlertPersistenceManager.shared
    @State private var isShowingSetAlertView = false
    
    private let aiService = AIService()

    // MARK: - BODY
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with Image and Titles
                HStack {
                    AsyncImage(url: URL(string: coin.image)) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.5))
                    }
                    .frame(width: 64, height: 64)
                    
                    VStack(alignment: .leading) {
                        Text(coin.name)
                            .font(.largeTitle)
                        Text(coin.symbol.uppercased())
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 20)
                
                // Overview Section
                Text("Overview")
                    .font(.title)
                    .fontWeight(.bold)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 20) {
                    StatisticView(title: "Current Price", value: coin.currentPrice.formatted(.currency(code: "usd")))
                    StatisticView(title: "Market Cap", value: (coin.marketCap ?? 0).formatted(.currency(code: "usd").notation(.compactName)))
                    StatisticView(title: "Rank", value: "#" + (coin.marketCapRank ?? 0).formatted())
                    StatisticView(title: "Volume", value: (coin.totalVolume ?? 0).formatted(.currency(code: "usd").notation(.compactName)))
                }
                
                Divider()
                // --- PASTE THIS ENTIRE BLOCK AFTER THE DIVIDER ---


                // --- PASTE THE BUTTON CODE HERE ---
                Button {
                    isShowingSetAlertView = true
                } label: {
                    let isAlertSet = alertManager.hasAlert(for: coin.id)
                    Label(isAlertSet ? "Update Alert" : "Set Price Alert",
                          systemImage: isAlertSet ? "bell.fill" : "bell")
                }
                .tint(alertManager.hasAlert(for: coin.id) ? .orange : .blue)
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, alignment: .center)
                .sheet(isPresented: $isShowingSetAlertView) {
                    SetAlertView(coin: coin)
                }

                Divider() // Add another divider for visual separation
                
                // Additional Details Section
                Text("Additional Details")
                    .font(.title)
                    .fontWeight(.bold)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 20) {
                    StatisticView(title: "24h High", value: (coin.high24h ?? 0).formatted(.currency(code: "usd")))
                    StatisticView(title: "24h Low", value: (coin.low24h ?? 0).formatted(.currency(code: "usd")))
                    
                    // The raw dollar value change from the API
                    let priceChangeValue = coin.priceChange24h ?? 0
                    
                    // The percentage change from the API
                    let percentageChange = coin.priceChangePercentage24h
                    
                    // Use the correct variables in the correct parameters
                    StatisticView(title: "24h Change",
                                  value: priceChangeValue.formatted(.currency(code: "usd")),
                                  percentageChange: percentageChange)
                }
                
                // AI Prediction Section
                // AI Prediction Section
                VStack(spacing: 15) {
                    // --- BASIC PREDICTION BUTTON ---
                    Button {
                        // First, check if the user can afford the request
                        if creditManager.spendCoins(amount: 10) {
                            isLoadingAI = true
                            predictionStatus = nil
                            predictionExplanation = nil
                            isAnalysisSaved = false
                            
                            // This Task performs the basic AI analysis we've already built
                            Task {
                                do {
                                    let fullResponse = try await aiService.fetchPrediction(for: coin)
                                    let trimmedResponse = fullResponse.trimmingCharacters(in: .whitespacesAndNewlines)
                                    
                                    var status: String?
                                    var explanation: String?
                                    
                                    let keywords = ["UP", "DOWN", "NEUTRAL"]
                                    if let foundKeyword = keywords.first(where: { trimmedResponse.uppercased().hasPrefix($0) }) {
                                        status = foundKeyword
                                        let explanationPart = trimmedResponse.dropFirst(foundKeyword.count)
                                        explanation = String(explanationPart).trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: ".:-")))
                                    } else {
                                        status = "NEUTRAL"
                                        explanation = trimmedResponse
                                    }
                                    
                                    await MainActor.run {
                                        self.predictionStatus = status
                                        self.predictionExplanation = explanation
                                        self.isLoadingAI = false
                                    }
                                } catch {
                                    print("DETAILED AI ERROR: \(error.localizedDescription)")
                                    await MainActor.run {
                                        self.predictionStatus = "ERROR"
                                        self.predictionExplanation = "Sorry, there was an error getting the analysis."
                                        self.isLoadingAI = false
                                    }
                                }
                            }
                        } else {
                            // If they don't have enough coins, trigger the alert
                            showNotEnoughCoinsAlert = true
                        }
                    } label: {
                        HStack {
                            Spacer()
                            VStack {
                                Text("Basic Analysis")
                                    .fontWeight(.bold)
                                Text("Cost: 10 Coins")
                                    .font(.caption)
                            }
                            Spacer()
                        }
                    }
                    .tint(.blue)
                    .buttonStyle(.borderedProminent)
                    
                    // --- ADVANCED PREDICTION BUTTON ---
                    Button {
                        if creditManager.spendCoins(amount: 20) {
                            isLoadingAI = true
                            predictionStatus = nil
                            predictionExplanation = nil
                            isAnalysisSaved = false
                            print("Advanced analysis initiated...")
                            Task {
                                do {
                                    // 1. Fetch the latest news from CryptoPanic
                                    let newsItems = try await networkManager.fetchNews(for: coin.symbol)
                                    self.newsPosts = newsItems
                                    
                                    // 2. Call the new AI function with the coin and news data
                                    let fullResponse = try await aiService.fetchAdvancedPrediction(for: coin, news: newsItems)
                                    
                                    // 3. The parsing logic remains exactly the same
                                    let trimmedResponse = fullResponse.trimmingCharacters(in: .whitespacesAndNewlines)
                                    var status: String?
                                    var explanation: String?
                                    let keywords = ["UP", "DOWN", "NEUTRAL"]
                                    if let foundKeyword = keywords.first(where: { trimmedResponse.uppercased().hasPrefix($0) }) {
                                        status = foundKeyword
                                        let explanationPart = trimmedResponse.dropFirst(foundKeyword.count)
                                        explanation = String(explanationPart).trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: ".:-")))
                                    } else {
                                        status = "NEUTRAL"
                                        explanation = trimmedResponse
                                    }

                                    await MainActor.run {
                                        self.predictionStatus = status
                                        self.predictionExplanation = explanation
                                        self.isLoadingAI = false
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                        } else {
                            showNotEnoughCoinsAlert = true
                        }
                    } label: {
                        HStack {
                            Spacer()
                            VStack {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Advanced Analysis")
                                        .fontWeight(.bold)
                                }
                                Text("Includes RSI & News | Cost: 20 Coins")
                                    .font(.caption)
                            }
                            Spacer()
                        }
                    }
                    .tint(.purple)
                    .buttonStyle(.borderedProminent)
                    
                    // --- Loading and Result Display Area ---
                    if isLoadingAI {
                        ProgressView().padding()
                    } else if let status = predictionStatus, let explanation = predictionExplanation {
                        PredictionView(status: status, explanation: explanation)
                            .padding(.top)
                        VStack {
//                                PredictionView(status: status, explanation: explanation)
//                                    .padding(.top)
                                
                                // --- ADD THIS BUTTON ---
                                Button {
                                    let newPrediction = SavedPrediction(id: UUID(), coinName: coin.name, coinSymbol: coin.symbol, status: status, explanation: explanation, savedDate: Date())
                                    PersistenceManager.shared.save(prediction: newPrediction)
                                    isAnalysisSaved = true
                                } label: {
                                    // Change the button's look after it's been tapped
                                    isAnalysisSaved ?
                                        Label("Saved ✔️", systemImage: "checkmark.circle.fill") :
                                        Label("Save Analysis", systemImage: "bookmark.fill")
                                }
                                .buttonStyle(.bordered)
                                .tint(.blue)
                                .disabled(isAnalysisSaved) // Disable the button after saving
                                .padding(.top)
                            }
                    }
                }
                .padding()
                // This alert will be shown if spendCoins() returns false
                .alert("Not Enough Coins", isPresented: $showNotEnoughCoinsAlert) {
                    Button("OK") {}
                } message: {
                    Text("You don't have enough coins for this analysis. You can add more from the main screen.")
                }
                .padding()
                
            }
            .padding()
            Button("DEBUG: Run Price Check Now") {
                Task {
                    await PriceCheckService.shared.checkPrices()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding()

        }
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - HELPER VIEWS

struct StatisticView: View {
    let title: String
    let value: String
    var percentageChange: Double? = nil

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Text(value)
                    .font(.headline)

                if let pc = percentageChange {
                    Text("\((pc).formatted(.number.precision(.fractionLength(2))))%")
                        .font(.caption)
                        .foregroundColor(pc >= 0 ? .green : .red)
                }
            }
        }
    }
}

struct PredictionView: View {
    let status: String
    let explanation: String
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Outlook")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: iconName)
                            .font(.title)
                        
                        Text(status)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(statusColor)
                }
                
                Spacer()
            }
            .padding()
            .background(statusColor.opacity(0.1))
            .cornerRadius(10)
            
            if !explanation.isEmpty {
                Text(explanation)
                    .font(.body)
                    .padding(.top, 8)
            }
            
            Text("Disclaimer: This AI-generated prediction is speculative, not financial advice, and may be inaccurate.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
    }
    
    private var statusColor: Color {
        switch status {
        case "UP": return .green
        case "DOWN": return .red
        case "ERROR": return .orange
        default: return .secondary
        }
    }
    
    private var iconName: String {
        switch status {
        case "UP": return "arrow.up.right.circle.fill"
        case "DOWN": return "arrow.down.right.circle.fill"
        case "ERROR": return "exclamationmark.triangle.fill"
        default: return "arrow.left.and.right.circle.fill"
        }
    }
}
