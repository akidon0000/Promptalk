import Foundation
import SwiftData

@MainActor
@Observable
final class SettingsViewStore {
    var apiKey: String = ""
    var speechRate: Float = 0.5
    var autoSpeak: Bool = true
    var isSaving: Bool = false

    private var modelContext: ModelContext?

    var hasAPIKey: Bool {
        KeychainService.shared.hasAPIKey
    }

    var maskedAPIKey: String {
        guard let key = KeychainService.shared.openAIAPIKey, !key.isEmpty else {
            return "未設定"
        }
        let prefix = String(key.prefix(8))
        let suffix = String(key.suffix(4))
        return "\(prefix)...\(suffix)"
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSettings()
    }

    private func loadSettings() {
        speechRate = UserDefaults.standard.float(forKey: "speechRate")
        if speechRate == 0 {
            speechRate = 0.5
        }
        autoSpeak = UserDefaults.standard.bool(forKey: "autoSpeak")
        if !UserDefaults.standard.bool(forKey: "autoSpeakSet") {
            autoSpeak = true
            UserDefaults.standard.set(true, forKey: "autoSpeakSet")
        }
    }

    func saveAPIKey() {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSaving = true
        KeychainService.shared.openAIAPIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        apiKey = ""
        isSaving = false
    }

    func deleteAPIKey() {
        KeychainService.shared.openAIAPIKey = nil
    }

    func saveSpeechRate() {
        UserDefaults.standard.set(speechRate, forKey: "speechRate")
    }

    func saveAutoSpeak() {
        UserDefaults.standard.set(autoSpeak, forKey: "autoSpeak")
    }

    func deleteAllConversations() {
        guard let modelContext else { return }

        do {
            let descriptor = FetchDescriptor<Conversation>()
            let conversations = try modelContext.fetch(descriptor)
            for conversation in conversations {
                modelContext.delete(conversation)
            }
            try modelContext.save()
        } catch {
            print("Failed to delete conversations: \(error)")
        }
    }

    func deleteAllCustomPersonas() {
        guard let modelContext else { return }

        do {
            let descriptor = FetchDescriptor<Persona>(
                predicate: #Predicate { !$0.isPreset }
            )
            let personas = try modelContext.fetch(descriptor)
            for persona in personas {
                modelContext.delete(persona)
            }
            try modelContext.save()
        } catch {
            print("Failed to delete custom personas: \(error)")
        }
    }
}
