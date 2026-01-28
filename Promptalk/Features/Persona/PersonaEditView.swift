import SwiftData
import SwiftUI

struct PersonaEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewStore = PersonaEditViewStore()

    let persona: Persona?
    var onSave: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("名前", text: $viewStore.name)

                    TextField("説明（日本語）", text: $viewStore.descriptionText)
                }

                Section("アイコン") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(PersonaEditViewStore.availableIcons, id: \.self) { icon in
                            Button {
                                viewStore.iconName = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        viewStore.iconName == icon
                                            ? Color.accentColor.opacity(0.2)
                                            : Color.clear
                                    )
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                viewStore.iconName == icon
                                                    ? Color.accentColor
                                                    : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    TextEditor(text: $viewStore.systemPrompt)
                        .frame(minHeight: 150)
                } header: {
                    Text("システムプロンプト")
                } footer: {
                    Text("AIの振る舞いを定義するプロンプトを英語で記述してください")
                }
            }
            .navigationTitle(viewStore.isEditing ? "ペルソナを編集" : "ペルソナを作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if viewStore.save() {
                            onSave?()
                            dismiss()
                        }
                    }
                    .disabled(!viewStore.isValid || viewStore.isSaving)
                }
            }
            .onAppear {
                viewStore.configure(modelContext: modelContext, persona: persona)
            }
        }
    }
}

#Preview {
    PersonaEditView(persona: nil)
        .modelContainer(for: [Persona.self, Conversation.self, Message.self], inMemory: true)
}
