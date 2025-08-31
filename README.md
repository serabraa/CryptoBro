# CryptoBro

CryptoBro: AI-Powered Crypto Tracker 🪙
An iOS application built with SwiftUI that allows users to track cryptocurrency prices, receive custom price alerts, and get AI-powered analysis and predictions on various coins.

(A good idea is to add a screenshot or a GIF of your app in action here)

About The Project
CryptoBro is a feature-rich crypto tracking application designed for both enthusiasts and newcomers. It provides real-time market data, live search, and a sophisticated alert system that works in the background. Its standout feature is a two-tiered AI analysis system, powered by GPT-5o, that uses a virtual currency to provide both basic market analysis and advanced analysis enriched with the latest news headlines.

Features
✅ Real-Time Price Tracking: Fetches and displays live market data for hundreds of cryptocurrencies.

✅ Live Search: Instantly search for any coin using the CoinGecko API.

✅ AI-Powered Analysis (GPT-5o):

Basic Analysis: Get a quick, AI-generated outlook on a coin's 24-hour performance.

Advanced Analysis: Provides a more insightful prediction by feeding the AI the latest news headlines from the CryptoPanic API.

✅ Virtual Credit System: Users have a balance of virtual coins to spend on AI analysis requests, with different costs for basic and advanced tiers.

✅ Custom Price Alerts: Set alerts for a coin to be notified when its price goes above or below a specific target.

✅ Background Notifications: Utilizes the iOS BackgroundTasks framework to periodically check prices even when the app is closed and sends a local notification if an alert condition is met.

✅ Saved Predictions: Users can save their favorite AI analyses to a persistent list for future reference.

✅ Secure API Key Management: Safely manages secret API keys using an .xcconfig file, which is kept out of version control via .gitignore.

Technologies & APIs Used
Frameworks: Swift, SwiftUI

Apple Services: BackgroundTasks, UserNotifications

APIs:

CoinGecko API: For all cryptocurrency market data.

OpenAI API: For the AI analysis and prediction feature (using the gpt-5o model).

CryptoPanic API: For fetching real-time, crypto-specific news headlines to enrich the AI prompts.

Setup and Configuration
To build and run this project, you will need to provide your own API keys.

Clone the repository to your local machine.

In the CryptoBro/ sub-directory (the one with the Swift code), create a new file named Key.xcconfig.

Add your secret API keys to this file in the following format (without quotes):

COINGECKO_API_KEY = YOUR_COINGECKO_KEY_HERE
OPENAI_API_KEY = YOUR_OPENAI_KEY_HERE
CRYPTOPANIC_API_KEY = YOUR_CRYPTOPANIC_KEY_HERE

Note: This file is listed in .gitignore and will not be uploaded to the repository.

In Xcode, go to your Project Settings (select the project, not the target) → Info tab. Under Configurations, set the "Based on Configuration File" for both Debug and Release to Key.xcconfig.

In your Target Settings → Info tab, add the keys to your Info.plist so the app can read them. The key should be CoinGeckoApiKey and the value should be $(COINGECKO_API_KEY), and so on for the other keys.
