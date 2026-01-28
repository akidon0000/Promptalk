import SwiftUI

struct PersonaRowView: View {
    let persona: Persona

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: persona.iconName)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 40, height: 40)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(persona.name)
                    .font(.headline)

                Text(persona.descriptionText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        PersonaRowView(
            persona: Persona(
                name: "Friendly Native",
                iconName: "person.fill",
                descriptionText: "フレンドリーなネイティブの友人",
                systemPrompt: "",
                isPreset: true
            )
        )
    }
}
