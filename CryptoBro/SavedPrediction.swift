//
//  SavedPrediction.swift
//  CryptoBro
//
//  Created by Sergey on 24.08.25.
//

import Foundation

struct SavedPrediction: Identifiable, Codable {
    let id: UUID
    let coinName: String
    let coinSymbol: String
    let status: String
    let explanation: String
    let savedDate: Date
}
