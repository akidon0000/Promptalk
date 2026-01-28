import Foundation
import SwiftData

enum MessageRole: String, Codable {
    case user
    case assistant
}

@Model
final class Message {
    var id: UUID
    var roleRawValue: String
    var content: String
    var translatedContent: String?
    var createdAt: Date
    var conversation: Conversation?

    var role: MessageRole {
        get { MessageRole(rawValue: roleRawValue) ?? .user }
        set { roleRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        translatedContent: String? = nil,
        createdAt: Date = Date(),
        conversation: Conversation? = nil
    ) {
        self.id = id
        self.roleRawValue = role.rawValue
        self.content = content
        self.translatedContent = translatedContent
        self.createdAt = createdAt
        self.conversation = conversation
    }
}
