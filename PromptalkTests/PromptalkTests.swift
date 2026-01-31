import Testing
@testable import Promptalk

@Suite("Promptalk Tests")
struct PromptalkTests {
    // MARK: - Message Tests

    @Suite("Message Model")
    struct MessageTests {
        @Test("Create user message")
        func createUserMessage() {
            let message = Message(role: .user, content: "Hello!")

            #expect(message.role == .user)
            #expect(message.roleRawValue == "user")
            #expect(message.content == "Hello!")
            #expect(message.translatedContent == nil)
        }

        @Test("Create assistant message")
        func createAssistantMessage() {
            let message = Message(role: .assistant, content: "Hi there!")

            #expect(message.role == .assistant)
            #expect(message.roleRawValue == "assistant")
            #expect(message.content == "Hi there!")
        }

        @Test("Message with translation")
        func messageWithTranslation() {
            let message = Message(
                role: .assistant,
                content: "How are you?",
                translatedContent: "お元気ですか？"
            )

            #expect(message.content == "How are you?")
            #expect(message.translatedContent == "お元気ですか？")
        }

        @Test("Update message role")
        func updateMessageRole() {
            let message = Message(role: .user, content: "Test")
            message.role = .assistant

            #expect(message.role == .assistant)
            #expect(message.roleRawValue == "assistant")
        }
    }

    // MARK: - Persona Tests

    @Suite("Persona Model")
    struct PersonaTests {
        @Test("Create custom persona")
        func createCustomPersona() {
            let persona = Persona(
                name: "Custom Teacher",
                iconName: "person.fill",
                descriptionText: "A custom English teacher",
                systemPrompt: "You are a helpful teacher.",
                isPreset: false
            )

            #expect(persona.name == "Custom Teacher")
            #expect(persona.iconName == "person.fill")
            #expect(persona.descriptionText == "A custom English teacher")
            #expect(persona.systemPrompt == "You are a helpful teacher.")
            #expect(persona.isPreset == false)
        }

        @Test("Create preset persona")
        func createPresetPersona() {
            let persona = Persona(
                name: "Friendly Native",
                iconName: "person.fill",
                descriptionText: "A friendly native speaker",
                systemPrompt: "You are friendly.",
                isPreset: true
            )

            #expect(persona.isPreset == true)
        }

        @Test("Persona has valid UUID")
        func personaHasValidUUID() {
            let persona = Persona(
                name: "Test",
                iconName: "star",
                descriptionText: "Test",
                systemPrompt: "Test"
            )

            #expect(persona.id != UUID())
        }
    }

    // MARK: - PresetPersonas Tests

    @Suite("PresetPersonas")
    struct PresetPersonasTests {
        @Test("All presets exist")
        func allPresetsExist() {
            let presets = PresetPersonas.all

            #expect(!presets.isEmpty)
            #expect(presets.count >= 5)
        }

        @Test("Preset has required fields")
        func presetHasRequiredFields() {
            for preset in PresetPersonas.all {
                #expect(!preset.name.isEmpty)
                #expect(!preset.iconName.isEmpty)
                #expect(!preset.descriptionText.isEmpty)
                #expect(!preset.systemPrompt.isEmpty)
            }
        }

        @Test("Preset converts to Persona correctly")
        func presetConvertsToPersona() {
            guard let firstPreset = PresetPersonas.all.first else {
                Issue.record("No presets available")
                return
            }

            let persona = firstPreset.toPersona()

            #expect(persona.name == firstPreset.name)
            #expect(persona.iconName == firstPreset.iconName)
            #expect(persona.descriptionText == firstPreset.descriptionText)
            #expect(persona.systemPrompt == firstPreset.systemPrompt)
            #expect(persona.isPreset == true)
        }
    }

    // MARK: - ChatMessage Tests

    @Suite("ChatMessage")
    struct ChatMessageTests {
        @Test("Create user chat message")
        func createUserChatMessage() {
            let message = ChatMessage(role: .user, content: "Hello")

            #expect(message.role == .user)
            #expect(message.content == "Hello")
        }

        @Test("Create assistant chat message")
        func createAssistantChatMessage() {
            let message = ChatMessage(role: .assistant, content: "Hi there")

            #expect(message.role == .assistant)
            #expect(message.content == "Hi there")
        }
    }

    // MARK: - ChatRole Tests

    @Suite("ChatRole")
    struct ChatRoleTests {
        @Test("ChatRole raw values")
        func chatRoleRawValues() {
            #expect(ChatRole.user.rawValue == "user")
            #expect(ChatRole.assistant.rawValue == "assistant")
        }
    }
}
