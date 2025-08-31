//
//  SavedPredictionsView.swift
//  CryptoBro
//
//  Created by Sergey on 24.08.25.
//

import SwiftUI

struct SavedPredictionsView: View {
    @StateObject private var persistenceManager = PersistenceManager.shared
    
    var body: some View {
        List {
            ForEach(persistenceManager.savedPredictions) { prediction in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(prediction.coinName)
                            .font(.title2.bold())
                        Text("(\(prediction.coinSymbol.uppercased()))")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(prediction.savedDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: iconName(for: prediction.status))
                        Text(prediction.status)
                            .fontWeight(.bold)
                    }
                    .font(.headline)
                    .foregroundColor(statusColor(for: prediction.status))
                    
                    Text(prediction.explanation)
                        .font(.body)
                        .padding(.top, 4)
                }
                .padding(.vertical)
            }
            .onDelete(perform: persistenceManager.delete) // Enable swipe-to-delete
        }
        .listStyle(.plain)
        .navigationTitle("Saved Analyses")
    }
    
    // Helper functions for styling the row
    private func statusColor(for status: String) -> Color {
        switch status {
        case "UP": return .green
        case "DOWN": return .red
        default: return .secondary
        }
    }
    
    private func iconName(for status: String) -> String {
        switch status {
        case "UP": return "arrow.up.right"
        case "DOWN": return "arrow.down.right"
        default: return "minus"
        }
    }
}
