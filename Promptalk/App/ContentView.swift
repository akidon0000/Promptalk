import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var selectedPersona: Persona?
    @State private var showConversation = false

    var body: some View {
        TabView(selection: $selectedTab) {
            PersonaListView { persona in
                selectedPersona = persona
                showConversation = true
            }
            .tabItem {
                Label("会話", systemImage: "message.fill")
            }
            .tag(0)

            HistoryListView()
                .tabItem {
                    Label("履歴", systemImage: "clock.fill")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .fullScreenCover(isPresented: $showConversation) {
            if let persona = selectedPersona {
                NavigationStack {
                    ConversationView(persona: persona)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Persona.self, Conversation.self, Message.self], inMemory: true)
}
