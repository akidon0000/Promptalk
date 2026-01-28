import Foundation
import KeychainAccess

final class KeychainService {
    static let shared = KeychainService()

    private let keychain: Keychain
    private let openAIAPIKeyKey = "openai_api_key"

    private init() {
        keychain = Keychain(service: "com.promptalk.app")
    }

    var openAIAPIKey: String? {
        get {
            try? keychain.get(openAIAPIKeyKey)
        }
        set {
            if let value = newValue {
                try? keychain.set(value, key: openAIAPIKeyKey)
            } else {
                try? keychain.remove(openAIAPIKeyKey)
            }
        }
    }

    var hasAPIKey: Bool {
        guard let key = openAIAPIKey else { return false }
        return !key.isEmpty
    }
}
