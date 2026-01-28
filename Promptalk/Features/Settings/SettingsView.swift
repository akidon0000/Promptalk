import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewStore = SettingsViewStore()
    @State private var showAPIKeyInput = false
    @State private var showDeleteConversationsAlert = false
    @State private var showDeletePersonasAlert = false
    @State private var showDeleteAPIKeyAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("OpenAI APIキー")
                        Spacer()
                        Text(viewStore.maskedAPIKey)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showAPIKeyInput = true
                    }

                    if viewStore.hasAPIKey {
                        Button(role: .destructive) {
                            showDeleteAPIKeyAlert = true
                        } label: {
                            Text("APIキーを削除")
                        }
                    }
                } header: {
                    Text("API設定")
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("読み上げ速度")
                        Slider(value: $viewStore.speechRate, in: 0.1...1.0, step: 0.1) {
                            Text("読み上げ速度")
                        }
                        .onChange(of: viewStore.speechRate) {
                            viewStore.saveSpeechRate()
                        }
                        HStack {
                            Text("遅い")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("速い")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Toggle("自動読み上げ", isOn: $viewStore.autoSpeak)
                        .onChange(of: viewStore.autoSpeak) {
                            viewStore.saveAutoSpeak()
                        }
                } header: {
                    Text("音声設定")
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConversationsAlert = true
                    } label: {
                        Text("会話履歴を削除")
                    }

                    Button(role: .destructive) {
                        showDeletePersonasAlert = true
                    } label: {
                        Text("カスタムペルソナを削除")
                    }
                } header: {
                    Text("データ管理")
                }

                Section {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("アプリ情報")
                }
            }
            .navigationTitle("設定")
            .sheet(isPresented: $showAPIKeyInput) {
                APIKeyInputView(apiKey: $viewStore.apiKey) {
                    viewStore.saveAPIKey()
                }
            }
            .alert("APIキーを削除", isPresented: $showDeleteAPIKeyAlert) {
                Button("削除", role: .destructive) {
                    viewStore.deleteAPIKey()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("APIキーを削除しますか？")
            }
            .alert("会話履歴を削除", isPresented: $showDeleteConversationsAlert) {
                Button("削除", role: .destructive) {
                    viewStore.deleteAllConversations()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("すべての会話履歴を削除しますか？この操作は取り消せません。")
            }
            .alert("カスタムペルソナを削除", isPresented: $showDeletePersonasAlert) {
                Button("削除", role: .destructive) {
                    viewStore.deleteAllCustomPersonas()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("すべてのカスタムペルソナを削除しますか？この操作は取り消せません。")
            }
            .onAppear {
                viewStore.configure(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Persona.self, Conversation.self, Message.self], inMemory: true)
}
