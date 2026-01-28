import Foundation
import SwiftData

@MainActor
@Observable
final class PersonaListViewStore {
    var presetPersonas: [Persona] = []
    var customPersonas: [Persona] = []
    var isLoading: Bool = false
    var error: Error?

    private var modelContext: ModelContext?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func loadPersonas() {
        guard let modelContext else { return }

        isLoading = true
        error = nil

        do {
            let descriptor = FetchDescriptor<Persona>(
                sortBy: [SortDescriptor(\.createdAt, order: .forward)]
            )
            let allPersonas = try modelContext.fetch(descriptor)

            presetPersonas = allPersonas.filter { $0.isPreset }
            customPersonas = allPersonas.filter { !$0.isPreset }

            if presetPersonas.isEmpty {
                seedPresetPersonas()
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    private func seedPresetPersonas() {
        guard let modelContext else { return }

        for data in PresetPersonas.all {
            let persona = data.toPersona()
            modelContext.insert(persona)
        }

        try? modelContext.save()
        loadPersonas()
    }

    func deleteCustomPersona(_ persona: Persona) {
        guard let modelContext, !persona.isPreset else { return }

        modelContext.delete(persona)
        try? modelContext.save()
        loadPersonas()
    }
}
