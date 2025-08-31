//
//  NotificationManager.swift
//  CryptoBro
//
//  Created by Sergey on 31.08.25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager() // Singleton for easy access
    
    // Asks the user for permission to send notifications when the app first starts.
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            } else if success {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    // Creates and schedules a local notification for a price alert.
    func schedulePriceAlertNotification(symbol: String, price: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Crypto Price Alert! 📈"
        content.body = "\(symbol.uppercased()) has reached your target price of \(price.formatted(.currency(code: "usd")))."
        content.sound = .default

        // Trigger the notification to appear immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
