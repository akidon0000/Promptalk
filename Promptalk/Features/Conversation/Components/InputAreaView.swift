import SwiftUI

struct InputAreaView: View {
    @Binding var text: String
    let isRecording: Bool
    let isLoading: Bool
    let audioLevels: [CGFloat]
    var onRecordStart: (() -> Void)?
    var onRecordEnd: (() -> Void)?
    var onSend: (() -> Void)?

    init(
        text: Binding<String>,
        isRecording: Bool,
        isLoading: Bool,
        audioLevels: [CGFloat] = [],
        onRecordStart: (() -> Void)? = nil,
        onRecordEnd: (() -> Void)? = nil,
        onSend: (() -> Void)? = nil
    ) {
        self._text = text
        self.isRecording = isRecording
        self.isLoading = isLoading
        self.audioLevels = audioLevels
        self.onRecordStart = onRecordStart
        self.onRecordEnd = onRecordEnd
        self.onSend = onSend
    }

    var body: some View {
        VStack(spacing: 12) {
            if isRecording {
                AudioWaveformView(levels: audioLevels)
                    .frame(height: 40)
                    .padding(.horizontal, 24)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }

            if !text.isEmpty || isRecording {
                HStack {
                    TextField("メッセージ", text: $text, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1...5)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    if !text.isEmpty {
                        Button {
                            text = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }

            HStack(spacing: 24) {
                RecordButton(
                    isRecording: isRecording,
                    onStart: onRecordStart,
                    onEnd: onRecordEnd
                )

                SendButton(
                    isEnabled: !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading,
                    isLoading: isLoading,
                    onTap: onSend
                )
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .animation(.easeInOut(duration: 0.2), value: isRecording)
    }
}

struct RecordButton: View {
    let isRecording: Bool
    var onStart: (() -> Void)?
    var onEnd: (() -> Void)?

    var body: some View {
        Button {
        } label: {
            ZStack {
                Circle()
                    .fill(isRecording ? Color.red : Color.accentColor)
                    .frame(width: 64, height: 64)

                Image(systemName: isRecording ? "waveform" : "mic.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isRecording {
                        onStart?()
                    }
                }
                .onEnded { _ in
                    onEnd?()
                }
        )
    }
}

struct SendButton: View {
    let isEnabled: Bool
    let isLoading: Bool
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack {
                Circle()
                    .fill(isEnabled ? Color.accentColor : Color(.systemGray4))
                    .frame(width: 64, height: 64)

                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }
        }
        .disabled(!isEnabled || isLoading)
    }
}

#Preview("With Text") {
    VStack {
        Spacer()
        InputAreaView(
            text: .constant("Hello!"),
            isRecording: false,
            isLoading: false
        )
    }
}

#Preview("Recording with Waveform") {
    VStack {
        Spacer()
        InputAreaView(
            text: .constant(""),
            isRecording: true,
            isLoading: false,
            audioLevels: (0..<30).map { _ in CGFloat.random(in: 0.1...0.7) }
        )
    }
}
