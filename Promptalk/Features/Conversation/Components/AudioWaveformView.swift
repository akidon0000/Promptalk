import SwiftUI

/// A visual representation of audio levels as an animated waveform
struct AudioWaveformView: View {
    let levels: [CGFloat]
    let barCount: Int
    let barSpacing: CGFloat
    let primaryColor: Color
    let secondaryColor: Color

    init(
        levels: [CGFloat],
        barCount: Int = 30,
        barSpacing: CGFloat = 3,
        primaryColor: Color = .red,
        secondaryColor: Color = .red.opacity(0.5)
    ) {
        self.levels = levels
        self.barCount = barCount
        self.barSpacing = barSpacing
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: barSpacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    WaveformBar(
                        level: safeLevel(at: index),
                        maxHeight: geometry.size.height,
                        primaryColor: primaryColor,
                        secondaryColor: secondaryColor
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func safeLevel(at index: Int) -> CGFloat {
        guard index < levels.count else { return 0 }
        return levels[index]
    }
}

private struct WaveformBar: View {
    let level: CGFloat
    let maxHeight: CGFloat
    let primaryColor: Color
    let secondaryColor: Color

    private var barHeight: CGFloat {
        let minHeight: CGFloat = 4
        let effectiveMaxHeight = maxHeight * 0.9
        return max(minHeight, level * effectiveMaxHeight)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: barHeight)
            .animation(.easeOut(duration: 0.08), value: level)
    }
}

#Preview("Active Recording") {
    AudioWaveformView(
        levels: (0..<30).map { _ in CGFloat.random(in: 0.1...0.8) }
    )
    .frame(height: 40)
    .padding()
    .background(Color(.systemGray6))
}

#Preview("Silent") {
    AudioWaveformView(
        levels: Array(repeating: 0.05, count: 30)
    )
    .frame(height: 40)
    .padding()
    .background(Color(.systemGray6))
}
