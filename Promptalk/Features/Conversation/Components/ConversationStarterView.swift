import SwiftUI

/// Displays suggested conversation starter phrases when the conversation is empty
struct ConversationStarterView: View {
    let onSelect: (String) -> Void

    private let starters: [StarterPhrase] = [
        StarterPhrase(
            text: "Hello! How are you today?",
            icon: "hand.wave.fill",
            category: "挨拶"
        ),
        StarterPhrase(
            text: "What do you like to do for fun?",
            icon: "sparkles",
            category: "趣味"
        ),
        StarterPhrase(
            text: "Can you tell me about yourself?",
            icon: "person.fill.questionmark",
            category: "自己紹介"
        ),
        StarterPhrase(
            text: "What's the weather like today?",
            icon: "cloud.sun.fill",
            category: "天気"
        ),
        StarterPhrase(
            text: "Do you have any recommendations?",
            icon: "star.fill",
            category: "おすすめ"
        ),
        StarterPhrase(
            text: "Could you explain that more simply?",
            icon: "questionmark.circle.fill",
            category: "確認"
        )
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("会話を始めてみましょう")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("フレーズをタップして送信できます")
                .font(.caption)
                .foregroundStyle(.tertiary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(starters) { starter in
                    StarterButton(phrase: starter) {
                        onSelect(starter.text)
                    }
                }
            }
        }
        .padding()
    }
}

private struct StarterPhrase: Identifiable {
    let id = UUID()
    let text: String
    let icon: String
    let category: String
}

private struct StarterButton: View {
    let phrase: StarterPhrase
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: phrase.icon)
                        .font(.caption)
                        .foregroundStyle(.accent)
                    Text(phrase.category)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(phrase.text)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ConversationStarterView { phrase in
        print("Selected: \(phrase)")
    }
}
