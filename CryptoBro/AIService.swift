import Foundation

class AIService {
    private let apiKey = APIConstants.openAIKey
//    private let model = "gpt-3.5-turbo"
    private let model = "gpt-5-mini"
    private let url = URL(string: "https://api.openai.com/v1/chat/completions")!

    func fetchPrediction(for coin: Coin) async throws -> String {
        let prompt = createPrompt(for: coin)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = APIRequestBody(model: model, messages: [Message(role: "user", content: prompt)])
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Decode the response into our new, flexible struct
        let response = try JSONDecoder().decode(APIResponse.self, from: data)
        
        // First, check if the API sent us a specific error message
        if let error = response.error {
            throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: error.message])
        }
        
        // If there's no error, get the content from the choices array
        guard let content = response.choices?.first?.message.content else {
            throw NSError(domain: "AIServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No message content found in response."])
        }
        
        return content
    }

    // In AIService.swift, replace the createPrompt function
    private func createPrompt(for coin: Coin) -> String {
        let price = coin.currentPrice.formatted(.currency(code: "usd"))
        let change = (coin.priceChangePercentage24h ?? 0).formatted(.number.precision(.fractionLength(2))) + "%"
        
        // This new prompt is very direct and asks for a structured response.
        return """
        Provide a brief, neutral analysis for the cryptocurrency \(coin.name) (\(coin.symbol.uppercased())) and provide a speculative outlook for the **next 24 hours**.
        
        IMPORTANT INSTRUCTIONS:
        1. Start your response with a SINGLE WORD: UP, DOWN, or NEUTRAL, representing the potential trend over the **next 24 hours**.
        2. After the single word, add a single line break.
        3. Then, provide a brief, high-level justification for your outlook in 2-3 sentences.
        4. DO NOT include any financial advice, price targets, or guarantees. This is purely a speculative analysis of the provided data points.

        Current Data:
        - Price: \(price)
        - 24-hour Change: \(change)
        - Market Cap: \((coin.marketCap ?? 0).formatted(.currency(code: "usd").notation(.compactName)))
        - Market Rank: \(coin.marketCapRank ?? 0)
        """
    }
    // In AIService.swift, add this new function
//    private func createPrompt(with customContent: String) -> String {
//        return """
//        \(customContent)
//
//        IMPORTANT INSTRUCTIONS:
//        1. Start your response with a SINGLE WORD: UP, DOWN, or NEUTRAL, representing the potential trend over the **next 24 hours**.
//        2. Follow with a single line break.
//        3. Provide a brief justification (2-3 sentences) based on the data.
//        4. DO NOT include financial advice or price targets.
//        """
//    }
    // In AIService.swift, add these new functions to the class

    // This is the new entry point for our advanced request
    func fetchAdvancedPrediction(for coin: Coin, news: [NewsPost]) async throws -> String {
        // 1. Create the new, detailed prompt string
        let prompt = createAdvancedPrompt(for: coin, news: news)
        
        // 2. The rest of this process is the same as the basic prediction
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = APIRequestBody(model: model, messages: [Message(role: "user", content: prompt)])
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try JSONDecoder().decode(APIResponse.self, from: data)
        
        if let error = response.error {
            throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: error.message])
        }
        
        guard let content = response.choices?.first?.message.content else {
            throw NSError(domain: "AIServiceError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No message content found in response."])
        }
        
        return content
    }

    // This helper function builds the advanced prompt string
    private func createAdvancedPrompt(for coin: Coin, news: [NewsPost]) -> String {
        let price = coin.currentPrice.formatted(.currency(code: "usd"))
        let change = (coin.priceChangePercentage24h ?? 0).formatted(.number.precision(.fractionLength(2))) + "%"
        
        // Take the top 3 news headlines and format them as a list
        let newsHeadlines = news.prefix(3).map { "- \($0.title)" }.joined(separator: "\n")

        return """
        Analyze the cryptocurrency \(coin.name) (\(coin.symbol.uppercased())) and provide a speculative outlook for the **next 24 hours**.
        
        IMPORTANT INSTRUCTIONS:
        1. Start your response with a SINGLE WORD: UP, DOWN, or NEUTRAL, representing the potential trend over the **next 24 hours**.
        2. Follow with a single line break.
        3. Provide a brief justification (2-3 sentences) that considers BOTH the market data and the sentiment from the news.
        4. DO NOT include financial advice or price targets.

        MARKET DATA:
        - Price: \(price)
        - 24-hour Change: \(change)

        RECENT NEWS HEADLINES:
        \(newsHeadlines.isEmpty ? "- No recent news available." : newsHeadlines)
        """
    }
}

// MARK: - Codable Structs for OpenAI API

struct APIRequestBody: Codable {
    let model: String
    let messages: [Message]
}

// This single response struct can handle BOTH success and error cases
struct APIResponse: Codable {
    let choices: [Choice]?
    let error: OpenAIError?
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let role: String
    let content: String
}

struct OpenAIError: Codable {
    let message: String
    let type: String?
}
