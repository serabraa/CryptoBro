//
//  PersistanceManager.swift
//  CryptoBro
//
//  Created by Sergey on 24.08.25.
//

import Foundation

class PersistenceManager: ObservableObject {
    static let shared = PersistenceManager()
    
    private let userDefaultsKey = "savedPredictionsKey"
    @Published var savedPredictions: [SavedPrediction] = []
    
    private init() {
        loadPredictions()
    }
    
    // Saves a new prediction and updates the array
    func save(prediction: SavedPrediction) {
        savedPredictions.append(prediction)
        commit()
    }
    
    // Deletes a prediction at a specific position in the list
    func delete(at offsets: IndexSet) {
        savedPredictions.remove(atOffsets: offsets)
        commit()
    }
    
    // Loads the array of predictions from UserDefaults
    private func loadPredictions() {
        guard
            let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let decodedPredictions = try? JSONDecoder().decode([SavedPrediction].self, from: data)
        else { return }
        
        self.savedPredictions = decodedPredictions
    }
    
    // Encodes the array to JSON and writes it to UserDefaults
    private func commit() {
        if let encodedData = try? JSONEncoder().encode(savedPredictions) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }
}
