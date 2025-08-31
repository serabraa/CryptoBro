//
//  CryptoBroApp.swift
//  CryptoBro
//
//  Created by Sergey on 21.08.25.
//
import SwiftUI
import BackgroundTasks

@main
struct CryptoTrackerApp: App {
    // This watches for when the app becomes active, goes to the background, etc.
    @Environment(\.scenePhase) private var scenePhase
    
    // The unique identifier for your background task.
    // This MUST match what's in your Info.plist.
    private let backgroundTaskIdentifier = "com.sergius.CryptoBro.priceCheck"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Ask for notification permission when the app starts
                    NotificationManager.shared.requestAuthorization()
                }
        }
        // This watches for the app going into the background and schedules the task.
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                print("App entered background. Scheduling price check.")
                schedulePriceCheck()
            }
        }
        // THIS IS THE CRUCIAL PART: It tells the app WHAT to do
        // when the background task is triggered by the OS.
        .backgroundTask(.appRefresh(backgroundTaskIdentifier)) {
            print("✅ BACKGROUND TASK: The system has triggered the task. Firing the price check service...")
            await PriceCheckService.shared.checkPrices()
            print("✅ BACKGROUND TASK: Price check service finished.")
        }
    }
    
    // Function to schedule the task with iOS
    private func schedulePriceCheck() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        // Tell iOS the earliest it can run this task is in 15 minutes
        request.earliestBeginDate = .now.addingTimeInterval(15 * 60)
//        request.earliestBeginDate = .now.addingTimeInterval(1 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task scheduled successfully.")
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }
    
    
}
