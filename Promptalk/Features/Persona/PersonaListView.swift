import SwiftData
import SwiftUI

struct PersonaListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewStore = PersonaListViewStore()
    @State private var showingEditSheet = false
    @State private var selectedPersona: Persona?

    var onSelectPersona: ((Persona) -> Void)?

    var body: some View {
        NavigationStack {
            List {
                if !viewStore.presetPersonas.isEmpty {
                    Section("プリセット") {
                        ForEach(viewStore.presetPersonas, id: \.id) { persona in
                            PersonaRowView(persona: persona)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onSelectPersona?(persona)
                                }
                        }
                    }
                }

                if !viewStore.customPersonas.isEmpty {
                    Section("カスタム") {
                        ForEach(viewStore.customPersonas, id: \.id) { persona in
                            PersonaRowView(persona: persona)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onSelectPersona?(persona)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        viewStore.deleteCustomPersona(persona)
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }

                                    Button {
                                        selectedPersona = persona
                                        showingEditSheet = true
                                    } label: {
                                        Label("編集", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }
            }
            .navigationTitle("ペルソナ")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        selectedPersona = nil
                        showingEditSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                PersonaEditView(persona: selectedPersona) {
                    viewStore.loadPersonas()
                }
            }
            .onAppear {
                viewStore.configure(modelContext: modelContext)
                viewStore.loadPersonas()
            }
        }
    }
}

#Preview {
    PersonaListView()
        .modelContainer(for: [Persona.self, Conversation.self, Message.self], inMemory: true)
}
