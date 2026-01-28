import SwiftData
import SwiftUI

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewStore = HistoryListViewStore()
    @State private var selectedConversation: Conversation?

    var body: some View {
        NavigationStack {
            Group {
                if viewStore.conversations.isEmpty {
                    ContentUnavailableView(
                        "履歴がありません",
                        systemImage: "clock",
                        description: Text("会話を開始すると、ここに履歴が表示されます")
                    )
                } else {
                    List {
                        ForEach(viewStore.conversations, id: \.id) { conversation in
                            HistoryRowView(conversation: conversation)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedConversation = conversation
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewStore.deleteConversation(conversation)
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("履歴")
            .navigationDestination(item: $selectedConversation) { conversation in
                ConversationView(conversation: conversation)
            }
            .onAppear {
                viewStore.configure(modelContext: modelContext)
                viewStore.loadConversations()
            }
        }
    }
}

#Preview {
    HistoryListView()
        .modelContainer(for: [Persona.self, Conversation.self, Message.self], inMemory: true)
}
