//
//  AlertPersistanceManager.swift
//  CryptoBro
//
//  Created by Sergey on 31.08.25.
//

import Foundation

class AlertPersistenceManager: ObservableObject {
    static let shared = AlertPersistenceManager()

    private let userDefaultsKey = "priceAlertsKey"
    @Published var alerts: [PriceAlert] = []

    private init() {
        loadAlerts()
        print("💾 PERSISTENCE: Loaded \(alerts.count) alerts from device storage.")
    }

    func save(alert: PriceAlert) {
        // Remove any existing alert for this coin before adding the new one
        print("💾 PERSISTENCE: Saving alert for \(alert.coinSymbol) to trigger when price is \(alert.direction.rawValue) \(alert.targetPrice).")
        alerts.removeAll { $0.id == alert.id }
        alerts.append(alert)
        commit()
    }

    func delete(for coinId: String) {
        print("💾 PERSISTENCE: Deleting alert for coin ID \(coinId).")
        alerts.removeAll { $0.id == coinId }
        commit()
    }

    func hasAlert(for coinId: String) -> Bool {
        alerts.contains { $0.id == coinId }
    }

    private func loadAlerts() {
        guard
            let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let decodedAlerts = try? JSONDecoder().decode([PriceAlert].self, from: data)
        else { return }
        self.alerts = decodedAlerts
    }

    private func commit() {
        if let encodedData = try? JSONEncoder().encode(alerts) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }
}
