import Foundation
import SwiftData

@Model
final class Conversation {
    var id: UUID
    var persona: Persona?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
    var messages: [Message] = []

    init(
        id: UUID = UUID(),
        persona: Persona? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.persona = persona
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var sortedMessages: [Message] {
        messages.sorted { $0.createdAt < $1.createdAt }
    }
}
