import SwiftUI

struct APIKeyInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var apiKey: String
    var onSave: (() -> Void)?

    @State private var inputKey = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("sk-...", text: $inputKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isFocused)
                } header: {
                    Text("OpenAI APIキー")
                } footer: {
                    Text("APIキーはOpenAIのダッシュボードから取得できます。キーは端末内のKeychainに安全に保存されます。")
                }
            }
            .navigationTitle("APIキーを設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        apiKey = inputKey
                        onSave?()
                        dismiss()
                    }
                    .disabled(inputKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
}

#Preview {
    APIKeyInputView(apiKey: .constant(""))
}
