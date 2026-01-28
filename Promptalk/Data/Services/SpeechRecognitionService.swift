import AVFoundation
import Speech

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

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

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

        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
