import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isTranslating: Bool
    var onTranslate: (() -> Void)?

    @State private var showTranslation = false

    private var isUser: Bool {
        message.role == .user
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if isUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 8) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(isUser ? Color.accentColor : Color(.systemGray5))
                    .foregroundStyle(isUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                if showTranslation, let translation = message.translatedContent {
                    Text(translation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    if message.translatedContent != nil {
                        showTranslation.toggle()
                    } else {
                        onTranslate?()
                        showTranslation = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        if isTranslating {
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                        Text(showTranslation ? "翻訳を隠す" : "翻訳")
                            .font(.caption)
                    }
                }
                .disabled(isTranslating)
                .foregroundStyle(.secondary)
            }

            if !isUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 16) {
        MessageBubbleView(
            message: Message(role: .assistant, content: "Hi! How are you today?"),
            isTranslating: false
        )
        MessageBubbleView(
            message: Message(role: .user, content: "I'm doing great, thanks!"),
            isTranslating: false
        )
    }
}
