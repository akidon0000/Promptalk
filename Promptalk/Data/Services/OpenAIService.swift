import Foundation

enum OpenAIError: LocalizedError {
    case apiKeyNotSet
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .apiKeyNotSet:
            return "APIキーが設定されていません"
        case .invalidURL:
            return "無効なURLです"
        case .invalidResponse:
            return "無効なレスポンスです"
        case let .httpError(statusCode, message):
            return "HTTPエラー(\(statusCode)): \(message)"
        case .decodingError(let error):
            return "デコードエラー: \(error.localizedDescription)"
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        }
    }
}

final class OpenAIService {
    static let shared = OpenAIService()

    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4o-mini"
    private let maxTokens = 500
    private let maxContextMessages = 30  // 15ターン = 30メッセージ

    private init() {}

    func sendMessage(
        systemPrompt: String,
        messages: [ChatMessage]
    ) async throws -> String {
        guard let apiKey = KeychainService.shared.openAIAPIKey, !apiKey.isEmpty else {
            throw OpenAIError.apiKeyNotSet
        }

        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }

        let recentMessages = Array(messages.suffix(maxContextMessages))

        var requestMessages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]

        for message in recentMessages {
            requestMessages.append([
                "role": message.role.rawValue,
                "content": message.content
            ])
        }

        let requestBody: [String: Any] = [
            "model": model,
            "messages": requestMessages,
            "max_tokens": maxTokens
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        let chatResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)

        guard let content = chatResponse.choices.first?.message.content else {
            throw OpenAIError.invalidResponse
        }

        return content
    }

    func translate(text: String) async throws -> String {
        guard let apiKey = KeychainService.shared.openAIAPIKey, !apiKey.isEmpty else {
            throw OpenAIError.apiKeyNotSet
        }

        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }

        let requestMessages: [[String: String]] = [
            [
                "role": "system",
                "content": "Translate the following English text to Japanese. Output only the translation."
            ],
            ["role": "user", "content": text]
        ]

        let requestBody: [String: Any] = [
            "model": model,
            "messages": requestMessages,
            "max_tokens": maxTokens
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        let chatResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)

        guard let content = chatResponse.choices.first?.message.content else {
            throw OpenAIError.invalidResponse
        }

        return content
    }
}

// MARK: - Request/Response Models

struct ChatMessage {
    let role: ChatRole
    let content: String
}

enum ChatRole: String {
    case user
    case assistant
}

private struct ChatCompletionResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: ResponseMessage
    }

    struct ResponseMessage: Decodable {
        let content: String
    }
}
