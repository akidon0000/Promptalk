import Foundation
import SwiftData

@Model
final class Persona {
    var id: UUID
    var name: String
    var iconName: String
    var descriptionText: String
    var systemPrompt: String
    var isPreset: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Conversation.persona)
    var conversations: [Conversation] = []

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        descriptionText: String,
        systemPrompt: String,
        isPreset: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.descriptionText = descriptionText
        self.systemPrompt = systemPrompt
        self.isPreset = isPreset
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
