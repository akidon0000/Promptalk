import Foundation
import SwiftData

@MainActor
@Observable
final class PersonaEditViewStore {
    var name: String = ""
    var iconName: String = "person.fill"
    var descriptionText: String = ""
    var systemPrompt: String = ""
    var isSaving: Bool = false
    var error: Error?

    private var modelContext: ModelContext?
    private var editingPersona: Persona?

    var isEditing: Bool {
        editingPersona != nil
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static let availableIcons: [String] = [
        "person.fill",
        "person.2.fill",
        "briefcase.fill",
        "airplane",
        "cup.and.saucer.fill",
        "swift",
        "laptopcomputer",
        "book.fill",
        "gamecontroller.fill",
        "music.note",
        "film.fill",
        "heart.fill",
        "star.fill",
        "globe",
        "building.2.fill"
    ]

    func configure(modelContext: ModelContext, persona: Persona?) {
        self.modelContext = modelContext
        self.editingPersona = persona

        if let persona {
            name = persona.name
            iconName = persona.iconName
            descriptionText = persona.descriptionText
            systemPrompt = persona.systemPrompt
        }
    }

    func save() -> Bool {
        guard let modelContext, isValid else { return false }

        isSaving = true
        error = nil

        if let editingPersona {
            editingPersona.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            editingPersona.iconName = iconName
            editingPersona.descriptionText = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
            editingPersona.systemPrompt = systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
            editingPersona.updatedAt = Date()
        } else {
            let newPersona = Persona(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                iconName: iconName,
                descriptionText: descriptionText.trimmingCharacters(in: .whitespacesAndNewlines),
                systemPrompt: systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines),
                isPreset: false
            )
            modelContext.insert(newPersona)
        }

        do {
            try modelContext.save()
            isSaving = false
            return true
        } catch {
            self.error = error
            isSaving = false
            return false
        }
    }
}
