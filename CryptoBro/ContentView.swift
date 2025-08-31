//
//  ContentView.swift
//  CryptoBro
//
//  Created by Sergey on 21.08.25.
//

import SwiftUI


struct ContentView: View {
    // MARK: - PROPERTIES
    
    // State for the main list of top coins
    @State private var coins: [Coin] = []
    
    // State variables for the search functionality
    @State private var searchText = ""
    @State private var searchResults: [SearchResultCoin] = []
    
    private let networkManager = NetworkManager()
    
    // At the top of ContentView
    @StateObject private var creditManager = CreditManager.shared

    // A computed property to determine if we are in search mode
    private var isSearching: Bool {
        !searchText.isEmpty
    }

    // MARK: - BODY

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            NavigationStack {
                List {
                    // Conditionally display search results or the main coin list
                    if isSearching {
                        searchResultsSection
                    } else {
                        mainCoinListSection
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden) // Makes the list background transparent
                .navigationTitle("CryptoBro")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: SavedPredictionsView()) {
                            Image(systemName: "bookmark.fill")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing){
                        
                        HStack {
                            HStack{
                                Image(systemName:"bitcoinsign.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("\(creditManager.coinBalance)")
                                    .font(.headline)
                            }
                            Button{
                                creditManager.addCoins(amount: 50)
                            } label:{ Image(systemName:"plus.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search for a coin...")
                .task(id: searchText) {
                    await fetchSearchResults()
                }
                .task {
                    await fetchInitialCoins()
                }
            }
        }
    }
}

// MARK: - PRIVATE VIEWS & FUNCTIONS

private extension ContentView {
    
    // The view for displaying search results
    private var searchResultsSection: some View {
        ForEach(searchResults) { coin in
            NavigationLink(destination: DetailLoadingView(coinId: coin.id)) {
                SearchResultRow(coin: coin)
            }
        }
    }
    
    // The view for displaying the main list of top coins
    private var mainCoinListSection: some View {
        ForEach(coins) { coin in
            NavigationLink(destination: CoinDetailView(coin: coin)) {
                CoinRow(coin: coin)
            }
        }
    }
    
    // Function to fetch the initial list of top coins
    private func fetchInitialCoins() async {
        // Prevent re-fetching if the list is already populated
        guard coins.isEmpty else { return }
        do {
            coins = try await networkManager.fetchCoins()
        } catch {
            print("Error fetching initial coins: \(error)")
            // Optionally, show an error alert to the user
        }
    }
    
    // Function to fetch search results based on the searchText
    private func fetchSearchResults() async {
        guard !searchText.isEmpty, searchText.count > 1 else {
            searchResults = [] // Clear results for short or empty queries
            return
        }
        
        do {
            searchResults = try await networkManager.searchCoins(query: searchText)
        } catch {
            print("Error searching coins: \(error)")
        }
    }
}

// MARK: - PREVIEW

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - ROW SUBVIEWS

// A dedicated view for a single row in the main coin list
struct CoinRow: View {
    let coin: Coin
    
    
    var body: some View {
//        let _ = print("""
//        --- DEBUG CoinRow: \(coin.name) ---
//        Current Price: \(coin.currentPrice)
//        24h Value Change (from API): \(coin.priceChangePercentage24h ?? 0)
//        24h Percent Change (from API): \(coin.priceChangePercentage24h ?? 0)
//        ------------------------------------
//        """)
        
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: coin.image)) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.5))
            }
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(coin.name)
                    .font(.headline)
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(coin.currentPrice.formatted(.currency(code: "usd")))
                    .font(.headline)
                
                Text("\((coin.priceChangePercentage24h ?? 0).formatted(.number.precision(.fractionLength(2))))%")
                    .font(.subheadline)
                    .foregroundColor((coin.priceChangePercentage24h ?? 0) >= 0 ? .green : .red)
            }
        }
    }
}

// A dedicated view for a single row in the search results
struct SearchResultRow: View {
    let coin: SearchResultCoin
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: coin.thumb)) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.5))
            }
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(coin.name)
                    .font(.headline)
                Text(coin.symbol.uppercased())
                    .font(.caption)
            }
        }
    }
}

#Preview {
    ContentView()
}
