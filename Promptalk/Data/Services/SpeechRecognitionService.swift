import AVFoundation
import Speech
import SwiftUI

enum SpeechRecognitionError: LocalizedError {
    case notAuthorized
    case notAvailable
    case recognitionFailed(Error?)

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "音声認識の権限がありません"
        case .notAvailable:
            return "音声認識が利用できません"
        case .recognitionFailed(let error):
            return "音声認識に失敗しました: \(error?.localizedDescription ?? "不明なエラー")"
        }
    }
}

@MainActor
final class SpeechRecognitionService: ObservableObject {
    @Published var recognizedText: String = ""
    @Published var isRecording: Bool = false
    @Published var error: SpeechRecognitionError?
    @Published var audioLevels: [CGFloat] = Array(repeating: 0, count: 30)

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var levelUpdateTimer: Timer?

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func startRecording() async throws {
        guard await requestAuthorization() else {
            error = .notAuthorized
            throw SpeechRecognitionError.notAuthorized
        }

        guard let speechRecognizer, speechRecognizer.isAvailable else {
            error = .notAvailable
            throw SpeechRecognitionError.notAvailable
        }

        stopRecording()

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest else {
            throw SpeechRecognitionError.recognitionFailed(nil)
        }

        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            self?.processAudioBuffer(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        isRecording = true
        recognizedText = ""
        error = nil

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, taskError in
            Task { @MainActor in
                guard let self else { return }

                if let result {
                    self.recognizedText = result.bestTranscription.formattedString
                }

                if taskError != nil || result?.isFinal == true {
                    self.stopRecording()
                }
            }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false
        levelUpdateTimer?.invalidate()
        levelUpdateTimer = nil

        Task { @MainActor in
            withAnimation(.easeOut(duration: 0.3)) {
                audioLevels = Array(repeating: 0, count: 30)
            }
        }

        try? AVAudioSession.sharedInstance().setActive(false)
    }

    nonisolated private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)

        var sum: Float = 0
        for i in 0..<frameLength {
            sum += abs(channelData[i])
        }
        let average = sum / Float(frameLength)

        // Convert to decibels and normalize to 0-1 range
        let decibels = 20 * log10(max(average, 0.0001))
        let normalizedLevel = CGFloat(max(0, min(1, (decibels + 50) / 50)))

        Task { @MainActor in
            withAnimation(.easeOut(duration: 0.05)) {
                var newLevels = self.audioLevels
                newLevels.removeFirst()
                newLevels.append(normalizedLevel)
                self.audioLevels = newLevels
            }
        }
    }
}
