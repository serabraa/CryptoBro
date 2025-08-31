//
//  SearchResult.swift
//  CryptoBro
//
//  Created by Sergey on 22.08.25.
//

import Foundation

// The overall structure of the JSON response from the search API
struct SearchResponse: Codable {
    let coins: [SearchResultCoin]
}

// The blueprint for a single coin from a search result
struct SearchResultCoin: Identifiable, Codable {
    let id: String
    let name: String
    let symbol: String
    let thumb: String // The URL for the thumbnail image
}
