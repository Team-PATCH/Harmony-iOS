//
//  AzureAIViewModel.swift
//  Harmony
//
//  Created by 한범석 on 8/3/24.
//

import SwiftUI
import AVFoundation
import Combine

final class AzureAIViewModel: ObservableObject {
    @Published var isChatting = false
    @Published var messages: [Message] = []
    @Published var currentMessage = "챗봇이 여기에다가 말함"
    @Published var isPlaying = false
    @Published var amplitude: CGFloat = 0
    @Published var continueChat = true
    @Published var recordingState = ""
    @Published var isChatEnded = false
    @Published var isSpeaking = false
    @Published var isRecording = false
    @Published var chatHistory: [ChatMessage] = []
    @Published var isViewAppeared = false
    @Published var forceUpdate: Bool = false
    @Published var initialPrompt: String = ""
    @Published var isInitialPromptLoaded: Bool = false
    @Published var isProcessing: Bool = false
    

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var silenceTimer: Timer?
    private var lastAudioLevel: Float = -160.0
    private let silenceDuration: TimeInterval = 2.0
    private var silenceStartTime: Date?
    
    private var memoryCardId: Int
    private let groupId: Int
    

    private let amplitudeThreshold: CGFloat = 0.1 // 진폭 임계값 추가
    private var amplitudeBuffer: [CGFloat] = []
    private let bufferSize = 5 // 버퍼 크기
    
    private var existingChatSession: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    
    init(chatMessages: [ChatMessage]? = nil, memoryCardId: Int, groupId: Int) {
        self.memoryCardId = memoryCardId
        self.groupId = groupId
        if let messages = chatMessages {
            self.chatHistory = messages
            self.isChatting = false
            self.currentMessage = ""
        } else {
            self.chatHistory = []
            self.isChatting = false
            self.currentMessage = ""
        }
    }

    func requestMicrophoneAccess() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                if granted {
                    print("Microphone access granted on iOS 17 or later")
                    self.startChat()
                } else {
                    print("Microphone access denied on iOS 17 or later")
                }
            }
        } else {
            // Fallback on earlier versions
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    print("Microphone access granted on iOS 16 or earlier")
                    self.startChat()
                } else {
                    print("Microphone access denied on iOS 16 or earlier")
                }
            }
        }
    }
    
    func updateUI() {
        forceUpdate.toggle()
    }
    
    
    func setInitialPrompt(_ prompt: String) {
        self.currentMessage = prompt
        if !self.chatHistory.contains(where: { $0.role == "assistant" && $0.content == prompt }) {
            self.chatHistory.append(ChatMessage(role: "assistant", content: prompt))
        }
    }
    
    func loadInitialPrompt(for memoryCardId: Int) {
        if isInitialPromptLoaded {
            return // 이미 로드된 경우 중복 요청 방지
        }
        
        MemoryCardService.shared.getInitialPrompt(mcId: memoryCardId)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Failed to load initial prompt: \(error)")
                }
                self?.isInitialPromptLoaded = true
            }, receiveValue: { [weak self] prompt in
                self?.initialPrompt = prompt
                self?.setInitialPrompt(prompt)
            })
            .store(in: &cancellables)
    }
    
    func startChat() {
        isChatting = true
        continueChat = true
        isChatEnded = false
        
        if chatHistory.isEmpty {
            loadInitialPrompt(for: memoryCardId)
        } else {
            currentMessage = "대화를 계속할까요?"
        }
        
        configureAudioSession()
        startRecording()
    }
    
     
    func endChat() {
        isChatting = false
        continueChat = false
        isChatEnded = true
        stopRecordingWithoutSending()
        audioPlayer?.stop()
        audioPlayer = nil
        currentMessage = "좋아요! 그럼 지금까지 나눈 추억 대화를 저장할게요.☺️"
        let history = ChatHistory(id: memoryCardId, date: Date(), messages: chatHistory)
        ChatHistoryManager.shared.saveChatHistory(history)
    }
    
    
    func endConversation() {
        isRecording = false
        isChatting = false
        stopRecordingWithoutSending()
        audioPlayer?.stop()
        audioPlayer = nil
        currentMessage = "좋아요! 그럼 지금까지 나눈 추억 대화를 저장할게요.☺️"
        
        if !chatHistory.isEmpty {
            if existingChatSession {
                MemoryCardService.shared.updateChatHistory(mcId: memoryCardId, groupId: groupId, messages: chatHistory)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("Chat history updated successfully")
                        case .failure(let error):
                            print("Failed to update chat history: \(error)")
                        }
                    }, receiveValue: { updatedMessages in
                        self.chatHistory = updatedMessages
                    })
                    .store(in: &cancellables)
            } else {
                MemoryCardService.shared.saveChatHistory(mcId: memoryCardId, groupId: groupId, messages: chatHistory)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("Chat history saved successfully")
                        case .failure(let error):
                            print("Failed to save chat history: \(error)")
                        }
                    }, receiveValue: { savedMessages in
                        self.chatHistory = savedMessages
                        self.existingChatSession = true
                    })
                    .store(in: &cancellables)
            }
        }
    }
    
    func stopConversationWithoutSaving() {
        isRecording = false
        isChatting = false
        stopRecordingWithoutSending()
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func loadInitialChatHistory() {
        print("loadInitialChatHistory 메서드 콜")
        MemoryCardService.shared.getChatHistory(mcId: memoryCardId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] messages in
                self?.chatHistory = messages
                self?.existingChatSession = !messages.isEmpty
            })
            .store(in: &cancellables)
    }
    
    
    func saveChatHistory() {
        let history = ChatHistory(id: memoryCardId, date: Date(), messages: chatHistory)
        ChatHistoryManager.shared.saveChatHistory(history)
        print("saveChatHistory Method Call for memory card \(memoryCardId)")
    }
    
    func resumeChat() {
        if !isChatting {
            isChatting = true
            if isViewAppeared {
                startRecording()
            }
        }
    }
    
    func viewAppeared() {
        isViewAppeared = true
        if isChatting {
            startRecording()
        }
    }
    
    func configureAudioSession() {
        print("Configuring audio session")
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
            try audioSession.setActive(true)
            print("Audio session configured successfully")
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func startRecording() {
        print("startRecording called")
        isProcessing = false  // 녹음 시작 시 처리 상태 초기화
        
        guard isViewAppeared else {
            print("View has not appeared yet, cannot start recording")
            return
        }
        
        configureAudioSession()
        
        if isChatEnded {
            print("Chat has ended. Not starting recording.")
            return
        }
        
        isRecording = true
        isSpeaking = false
        isProcessing = false
        recordingState = "목소리 듣는 중..."
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = makeCoordinator()
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            Timer.scheduledTimer(withTimeInterval: 1.0 / 120.0, repeats: true) { timer in
                guard let recorder = self.audioRecorder, !self.isChatEnded else {
                    timer.invalidate()
                    return
                }
                
                recorder.updateMeters()
                let audioLevel = CGFloat(recorder.averagePower(forChannel: 0))
                
                DispatchQueue.main.async {
                    self.updateAmplitude(audioLevel)
                }
                
                if audioLevel > -20 {
                    self.isSpeaking = true
                    self.silenceStartTime = nil
                } else if self.isSpeaking {
                    if self.silenceStartTime == nil {
                        self.silenceStartTime = Date()
                    } else if Date().timeIntervalSince(self.silenceStartTime!) > self.silenceDuration {
                        self.isSpeaking = false
                        self.stopRecordingAndSendData()
                        timer.invalidate()
                    }
                }
            }
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    private func updateAmplitude(_ newValue: CGFloat) {
        let normalizedValue = (newValue + 160) / 160
        
        amplitudeBuffer.append(normalizedValue)
        if amplitudeBuffer.count > bufferSize {
            amplitudeBuffer.removeFirst()
        }
        
        let averageAmplitude = amplitudeBuffer.reduce(0, +) / CGFloat(amplitudeBuffer.count)
        
        amplitude = max(averageAmplitude, 0)
        
        updateUI()
    }
    
    func stopRecordingAndSendData() {
        guard let recorder = audioRecorder else { return }
        
        recorder.stop()
        audioRecorder = nil
        amplitude = 0
        isSpeaking = false
        silenceStartTime = nil
        isRecording = false
        isProcessing = true
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        if FileManager.default.fileExists(atPath: audioFilename.path) {
            if let data = try? Data(contentsOf: audioFilename) {
                self.sendAudioData(data)
            }
        }
    }
    
    func stopRecordingWithoutSending() {
        audioRecorder?.stop()
        audioRecorder = nil
        amplitude = 0
        isSpeaking = false
        silenceStartTime = nil
        isRecording = false
    }
    
    func sendAudioData(_ audioData: Data) {
        if isChatEnded {
            print("Chat has ended. Not sending audio data.")
            return
        }
        
        print("stop recording and STT processing...")
        recordingState = "대답 준비 중..."
        isProcessing = true  // 처리 시작
        
        AzureSpeechService.shared.recognizeSpeech(audioData: audioData) { [weak self] recognizedText in
            guard let self = self else { return }
            
            print("Recognized text: \(recognizedText)")
            self.saveAudioData(audioData, isUser: true, content: recognizedText)
            let userMessage = ChatMessage(role: "user", content: recognizedText)
            
            AzureSpeechService.shared.chatWithGPT4(messages: self.chatHistory) { responseText in
                if self.isChatEnded {
                    print("Chat has ended. Not processing chat response.")
                    self.isProcessing = false  // 처리 시작
                    return
                }
                
                print("Chat response text: \(responseText)")
                let assistantMessage = ChatMessage(role: "assistant", content: responseText)
                self.currentMessage = responseText
                self.recordingState = ""
                
                AzureSpeechService.shared.synthesizeSpeech(text: responseText) { audioURL in
                    self.isProcessing = false
                    self.isSpeaking = true
                    if let audioData = try? Data(contentsOf: audioURL) {
                        self.saveAudioData(audioData, isUser: false, content: responseText)
                    }
                    if self.isChatEnded {
                        print("Chat has ended. Not playing audio.")
                        return
                    }
                    
                    print("Audio file URL: \(audioURL)")
                    if FileManager.default.fileExists(atPath: audioURL.path) {
                        print("Synthesized audio file exists at path: \(audioURL.path)")
                        self.playAudio(url: audioURL) {
                            if self.continueChat {
                                self.startRecording()
                            }
                        }
                    } else {
                        print("Synthesized audio file does not exist at path: \(audioURL.path)")
                        self.startRecording()
                    }
                }
            }
        }
    }
    
    func saveAudioData(_ audioData: Data, isUser: Bool, content: String) {
        let fileName = "\(memoryCardId)_\(Date().timeIntervalSince1970)_\(isUser ? "user" : "bot").wav"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try audioData.write(to: fileURL)
            print("Audio file saved at: \(fileURL.path)")
            
            let audioDuration = getAudioDuration(url: fileURL)
            let audioRecord = AudioRecord(fileName: fileName, isUser: isUser, duration: audioDuration)
            let newMessage = ChatMessage(role: isUser ? "user" : "assistant", content: content, audioRecord: audioRecord)
            
            chatHistory.append(newMessage)
            print("New message added to chat history: \(newMessage.content)")
        } catch {
            print("Failed to save audio data: \(error)")
        }
    }
    
    func getAudioDuration(url: URL) -> TimeInterval {
        let asset = AVAsset(url: url)
        
        if #available(iOS 16.0, *) {
            let duration = asset.duration
            return duration.seconds
        } else {
            let duration = asset.duration
            return duration.seconds
        }
    }
    
    func playAudio(url: URL, completion: @escaping () -> Void) {
        do {
            print("Playing audio from URL: \(url)")
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = makeCoordinator()
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            isSpeaking = true  // 음성 재생 시작
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (audioPlayer?.duration ?? 0)) {
                self.isPlaying = false
                self.isSpeaking = false  // 음성 재생 종료
                completion()
            }
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
            isPlaying = false
            isSpeaking = false
            completion()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
        var parent: AzureAIViewModel
        
        init(_ parent: AzureAIViewModel) {
            self.parent = parent
        }
        
        func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
            if flag {
                if let data = try? Data(contentsOf: recorder.url) {
                    parent.sendAudioData(data)
                }
            } else {
                print("Recording failed")
            }
        }
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            parent.isPlaying = false
            if parent.continueChat {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.parent.startRecording()
                }
            }
        }
    }
}





