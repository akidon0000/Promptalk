import SwiftUI

struct HistoryRowView: View {
    let conversation: Conversation

    private var personaName: String {
        conversation.persona?.name ?? "不明なペルソナ"
    }

    private var personaIcon: String {
        conversation.persona?.iconName ?? "questionmark.circle"
    }

    private var lastMessage: String {
        conversation.sortedMessages.last?.content ?? "メッセージなし"
    }

    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: conversation.updatedAt, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: personaIcon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 36, height: 36)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(personaName)
                        .font(.headline)

                    Spacer()

                    Text(formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(lastMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        HistoryRowView(
            conversation: {
                let persona = Persona(
                    name: "Friendly Native",
                    iconName: "person.fill",
                    descriptionText: "フレンドリーなネイティブの友人",
                    systemPrompt: "",
                    isPreset: true
                )
                let conversation = Conversation(persona: persona)
                return conversation
            }()
        )
    }
}
