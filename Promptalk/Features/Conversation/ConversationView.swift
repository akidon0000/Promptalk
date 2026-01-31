import SwiftData
import SwiftUI

struct ConversationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewStore = ConversationViewStore()
    @State private var showAPIKeyAlert = false
    @State private var showErrorAlert = false

    let persona: Persona?
    let existingConversation: Conversation?

    init(persona: Persona) {
        self.persona = persona
        self.existingConversation = nil
    }

    init(conversation: Conversation) {
        self.persona = nil
        self.existingConversation = conversation
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewStore.messages, id: \.id) { message in
                            MessageBubbleView(
                                message: message,
                                isTranslating: viewStore.translatingMessageId == message.id
                            ) {
                                Task {
                                    await viewStore.translate(message)
                                }
                            }
                            .id(message.id)
                        }

                        if viewStore.isLoading {
                            HStack {
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                            .padding(.horizontal)
                        }

                        if viewStore.showRetry {
                            Button {
                                Task {
                                    await viewStore.retry()
                                }
                            } label: {
                                Label("リトライ", systemImage: "arrow.clockwise")
                            }
                            .buttonStyle(.bordered)
                            .padding()
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: viewStore.messages.count) {
                    if let lastMessage = viewStore.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            InputAreaView(
                text: $viewStore.inputText,
                isRecording: viewStore.isRecording,
                isLoading: viewStore.isLoading,
                onRecordStart: {
                    Task {
                        await viewStore.startRecording()
                    }
                },
                onRecordEnd: {
                    viewStore.stopRecording()
                },
                onSend: {
                    Task {
                        await viewStore.send()
                    }
                }
            )
        }
        .navigationTitle(viewStore.currentPersona?.name ?? "会話")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("終了") {
                    viewStore.endConversation()
                    dismiss()
                }
            }
        }
        .alert("APIキーが必要です", isPresented: $showAPIKeyAlert) {
            Button("設定へ") {
                dismiss()
            }
            Button("キャンセル", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("会話を開始するにはOpenAI APIキーを設定してください。")
        }
        .alert("エラーが発生しました", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {
                viewStore.clearError()
            }
        } message: {
            Text(viewStore.errorMessage)
        }
        .onChange(of: viewStore.error != nil) { _, hasError in
            showErrorAlert = hasError
        }
        .onAppear {
            if !viewStore.hasAPIKey {
                showAPIKeyAlert = true
                return
            }

            if let existingConversation {
                viewStore.resumeConversation(modelContext: modelContext, conversation: existingConversation)
            } else if let persona {
                viewStore.configure(modelContext: modelContext, persona: persona)
            }
        }
        .onDisappear {
            viewStore.stopSpeaking()
        }
        .onChange(of: viewStore.speechService.recognizedText) { _, newValue in
            if viewStore.isRecording {
                viewStore.inputText = newValue
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConversationView(
            persona: Persona(
                name: "Test Persona",
                iconName: "person.fill",
                descriptionText: "Test",
                systemPrompt: "You are a helpful assistant.",
                isPreset: true
            )
        )
    }
    .modelContainer(for: [Persona.self, Conversation.self, Message.self], inMemory: true)
}
