import Foundation
import SwiftData

@MainActor
@Observable
final class ConversationViewStore {
    var messages: [Message] = []
    var inputText: String = ""
    var isRecording: Bool = false
    var isLoading: Bool = false
    var isSpeaking: Bool = false
    var error: Error?
    var showRetry: Bool = false
    var translatingMessageId: UUID?

    private(set) var currentPersona: Persona?
    private(set) var currentConversation: Conversation?

    private var modelContext: ModelContext?
    private let openAIService = OpenAIService.shared
    let speechService = SpeechRecognitionService()
    let ttsService = TextToSpeechService()

    var hasAPIKey: Bool {
        KeychainService.shared.hasAPIKey
    }

    func configure(modelContext: ModelContext, persona: Persona) {
        self.modelContext = modelContext
        self.currentPersona = persona

        let conversation = Conversation(persona: persona)
        modelContext.insert(conversation)
        try? modelContext.save()
        self.currentConversation = conversation
    }

    func resumeConversation(modelContext: ModelContext, conversation: Conversation) {
        self.modelContext = modelContext
        self.currentConversation = conversation
        self.currentPersona = conversation.persona
        self.messages = conversation.sortedMessages
    }

    func startRecording() async {
        do {
            try await speechService.startRecording()
            isRecording = true
            inputText = ""
        } catch {
            self.error = error
        }
    }

    func stopRecording() {
        speechService.stopRecording()
        isRecording = false
        inputText = speechService.recognizedText
    }

    func send() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let modelContext, let currentConversation, let currentPersona else { return }

        let userContent = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = ""
        showRetry = false
        error = nil

        let userMessage = Message(role: .user, content: userContent)
        userMessage.conversation = currentConversation
        modelContext.insert(userMessage)
        messages.append(userMessage)

        isLoading = true

        do {
            let chatMessages = messages.map {
                ChatMessage(role: ChatRole(rawValue: $0.roleRawValue) ?? .user, content: $0.content)
            }
            let response = try await openAIService.sendMessage(
                systemPrompt: currentPersona.systemPrompt,
                messages: chatMessages
            )

            let assistantMessage = Message(role: .assistant, content: response)
            assistantMessage.conversation = currentConversation
            modelContext.insert(assistantMessage)
            messages.append(assistantMessage)

            currentConversation.updatedAt = Date()
            try? modelContext.save()

            let speechRate = UserDefaults.standard.float(forKey: "speechRate")
            let autoSpeak = UserDefaults.standard.bool(forKey: "autoSpeak")
            if autoSpeak {
                ttsService.speak(response, rate: speechRate > 0 ? speechRate : 0.5)
            }
        } catch {
            self.error = error
            self.showRetry = true
        }

        isLoading = false
    }

    func retry() async {
        guard let lastUserMessage = messages.last(where: { $0.role == .user }) else { return }
        inputText = lastUserMessage.content

        if let modelContext, messages.last?.role == .user {
            modelContext.delete(messages.removeLast())
            try? modelContext.save()
        }

        await send()
    }

    func translate(_ message: Message) async {
        guard message.translatedContent == nil else { return }

        translatingMessageId = message.id

        do {
            let translation = try await openAIService.translate(text: message.content)
            message.translatedContent = translation
            try? modelContext?.save()
        } catch {
            self.error = error
        }

        translatingMessageId = nil
    }

    func stopSpeaking() {
        ttsService.stop()
    }

    func endConversation() {
        stopSpeaking()
        speechService.stopRecording()

        if let conversation = currentConversation, messages.isEmpty, let modelContext {
            modelContext.delete(conversation)
            try? modelContext.save()
        }
    }
}
