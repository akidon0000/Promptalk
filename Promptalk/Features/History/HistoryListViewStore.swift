import Foundation
import SwiftData

@MainActor
@Observable
final class HistoryListViewStore {
    var conversations: [Conversation] = []
    var isLoading: Bool = false
    var error: Error?

    private var modelContext: ModelContext?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func loadConversations() {
        guard let modelContext else { return }

        isLoading = true
        error = nil

        do {
            let descriptor = FetchDescriptor<Conversation>(
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
            let allConversations = try modelContext.fetch(descriptor)
            conversations = allConversations.filter { !$0.messages.isEmpty }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func deleteConversation(_ conversation: Conversation) {
        guard let modelContext else { return }

        modelContext.delete(conversation)
        try? modelContext.save()
        loadConversations()
    }

    func deleteAllConversations() {
        guard let modelContext else { return }

        for conversation in conversations {
            modelContext.delete(conversation)
        }
        try? modelContext.save()
        conversations = []
    }
}
