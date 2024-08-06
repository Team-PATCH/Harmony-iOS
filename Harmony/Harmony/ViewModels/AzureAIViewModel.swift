//
//  AzureAIViewModel.swift
//  Harmony
//
//  Created by 한범석 on 8/3/24.
//

// MARK: - 1차 동작 버전

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

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var silenceTimer: Timer?
    private var lastAudioLevel: Float = -160.0
    private let silenceDuration: TimeInterval = 2.0
    private var silenceStartTime: Date?
//    private var chatId: UUID
    private var memoryCardId: Int
    private let groupId: Int
    

    private let amplitudeThreshold: CGFloat = 0.1 // 진폭 임계값 추가
    private var amplitudeBuffer: [CGFloat] = []
    private let bufferSize = 5 // 버퍼 크기
    
    
    
    private var cancellables = Set<AnyCancellable>()
    
    /*
    init(chatHistory: ChatHistory? = nil, memoryCardId: Int) {
        self.memoryCardId = memoryCardId
        
        if let history = chatHistory {
            self.chatHistory = history.messages
            self.isChatting = true  // 대화를 바로 시작하도록 설정
            self.currentMessage = "이전 대화를 불러왔습니다. 계속해서 대화를 이어갑니다."
        } else {
            self.chatHistory = []
            self.isChatting = false
            self.currentMessage = "대화를 시작해주세요."
        }
    }
    */
    
    init(chatMessages: [ChatMessage]? = nil, memoryCardId: Int, groupId: Int) {
        self.memoryCardId = memoryCardId
        self.groupId = groupId
        if let messages = chatMessages {
            self.chatHistory = messages
            self.isChatting = false
            self.currentMessage = "이전 대화를 불러왔습니다. 대화 시작하기 버튼을 눌러 대화를 이어가세요."
        } else {
            self.chatHistory = []
            self.isChatting = false
            self.currentMessage = "대화를 시작해주세요."
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
    
    /*
    func startChat() {
        isChatting = true
        continueChat = true
        isChatEnded = false
        chatHistory = [] // 대화 히스토리 초기화
        currentMessage = "대화 시작됨."
        configureAudioSession()
        startRecording()
    }
     */
    func startChat() {
        isChatting = true
        continueChat = true
        isChatEnded = false
        chatHistory = []
        
        MemoryCardService.shared.getInitialPrompt(mcId: memoryCardId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Failed to get initial prompt: \(error)")
                    self.currentMessage = "대화를 시작합니다."
                    self.configureAudioSession()
                    self.startRecording()
                }
            }, receiveValue: { prompt in
                print("Successfully to get initial prompt.")
                self.currentMessage = prompt
                self.configureAudioSession()
                self.startRecording()
            })
            .store(in: &cancellables)
    }
    
    func endChat() {
        isChatting = false
        continueChat = false
        isChatEnded = true
        stopRecordingWithoutSending()
        audioPlayer?.stop()
        audioPlayer = nil
        currentMessage = "대화가 종료되었습니다."
        let history = ChatHistory(id: memoryCardId, date: Date(), messages: chatHistory)
        ChatHistoryManager.shared.saveChatHistory(history)
    }
    
    /*
    func endConversation() {
        isRecording = false
        isChatting = false
        stopRecordingWithoutSending()
        audioPlayer?.stop()
        audioPlayer = nil
        currentMessage = "좋아요! 대화를 종료하고 기록을 저장했어요."
        saveChatHistory()
        print("endConversation Method Call")
    }
     */
    
    /*
    // MARK: - 동작 버전
    func endConversation() {
        isRecording = false
        isChatting = false
        stopRecordingWithoutSending()
        audioPlayer?.stop()
        audioPlayer = nil
        currentMessage = "좋아요! 대화를 종료하고 기록을 저장했어요."
        
        // 서버에 채팅 기록 저장
        MemoryCardService.shared.saveChatHistory(mcId: memoryCardId, messages: chatHistory)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Chat history saved to server successfully")
                case .failure(let error):
                    print("Failed to save chat history to server: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        // 로컬에 채팅 기록 저장
        let history = ChatHistory(id: memoryCardId, date: Date(), messages: chatHistory)
        ChatHistoryManager.shared.saveChatHistory(history)
        print("saveChatHistory Method Call for memory card \(memoryCardId)")
    }
    */
    
    /*
    // MARK: - 0805 최종 동작 버전
    func endConversation() {
        isRecording = false
        isChatting = false
        stopRecordingWithoutSending()
        audioPlayer?.stop()
        audioPlayer = nil
        currentMessage = "좋아요! 대화를 종료하고 기록을 저장했어요."
        
        // 서버에 채팅 기록 저장
        MemoryCardService.shared.saveChatHistory(mcId: memoryCardId, groupId: groupId, messages: chatHistory)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Chat history saved to server successfully")
                case .failure(let error):
                    print("Failed to save chat history to server: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        // 로컬에 채팅 기록 저장
        let history = ChatHistory(id: memoryCardId, date: Date(), messages: chatHistory)
        ChatHistoryManager.shared.saveChatHistory(history)
        print("saveChatHistory Method Call for memory card \(memoryCardId)")
    }
     */
    func endConversation() {
        isRecording = false
        isChatting = false
        stopRecordingWithoutSending()
        audioPlayer?.stop()
        audioPlayer = nil
        currentMessage = "좋아요! 대화를 종료하고 기록을 저장했어요."
        
        MemoryCardService.shared.saveChatHistory(mcId: memoryCardId, groupId: groupId, messages: chatHistory)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Chat history saved to server successfully")
                case .failure(let error):
                    print("Failed to save chat history to server: \(error)")
                }
            }, receiveValue: { updatedMessages in
                self.chatHistory = updatedMessages
            })
            .store(in: &cancellables)
        
        print("endConversation Method Call")
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
                
                if audioLevel > -30 {
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
        
        AzureSpeechService.shared.recognizeSpeech(audioData: audioData) { [weak self] recognizedText in
            guard let self = self else { return }
            
            print("Recognized text: \(recognizedText)")
            self.saveAudioData(audioData, isUser: true, content: recognizedText)
            let userMessage = ChatMessage(role: "user", content: recognizedText)
            
            AzureSpeechService.shared.chatWithGPT4(messages: self.chatHistory) { responseText in
                if self.isChatEnded {
                    print("Chat has ended. Not processing chat response.")
                    return
                }
                
                print("Chat response text: \(responseText)")
                let assistantMessage = ChatMessage(role: "assistant", content: responseText)
                self.currentMessage = responseText
                self.recordingState = ""
                
                AzureSpeechService.shared.synthesizeSpeech(text: responseText) { audioURL in
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (audioPlayer?.duration ?? 0)) {
                completion()
            }
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
            isPlaying = false
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


/*
import SwiftUI
import AVFoundation

class AzureAIViewModel: ObservableObject {
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
    var memoryCardUUID: UUID?
    
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var silenceTimer: Timer?
    private var lastAudioLevel: Float = -160.0
    private let silenceDuration: TimeInterval = 2.0
    private var silenceStartTime: Date?
    private var chatId: UUID
    
    private let amplitudeThreshold: CGFloat = 0.1
    private var amplitudeBuffer: [CGFloat] = []
    private let bufferSize = 5
    
    init(chatHistory: ChatHistory? = nil) {
        if let history = chatHistory {
            self.chatHistory = history.messages
            self.chatId = history.id
            self.isChatting = true
            self.currentMessage = "이전 대화를 불러왔습니다. 계속해서 대화를 이어갑니다."
        } else {
            self.chatId = UUID()
        }
    }

    func loadChatHistory(memoryCardId: Int) {
        let histories = ChatHistoryManager.shared.loadChatHistories()
        if let history = histories.first(where: { $0.id.uuidString == String(memoryCardId) }) {
            self.chatHistory = history.messages
            self.chatId = history.id
            self.isChatting = true
        }
    }
    
    func saveChatHistory() {
        guard let memoryCardUUID = memoryCardUUID else { return }
        let history = ChatHistory(id: memoryCardUUID, date: Date(), messages: chatHistory)
        ChatHistoryManager.shared.saveChatHistory(history)
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
    
    func startChat() {
        isChatting = true
        continueChat = true
        isChatEnded = false
        chatHistory = []
        currentMessage = "대화 시작됨."
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
        currentMessage = "대화가 종료되었습니다."
        saveChatHistory()
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
                
                if audioLevel > -30 {
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
        
        AzureSpeechService.shared.recognizeSpeech(audioData: audioData) { [weak self] recognizedText in
            guard let self = self else { return }
            
            print("Recognized text: \(recognizedText)")
            self.saveAudioData(audioData, isUser: true, content: recognizedText)
            let userMessage = ChatMessage(role: "user", content: recognizedText)
            
            AzureSpeechService.shared.chatWithGPT4(messages: self.chatHistory) { responseText in
                if self.isChatEnded {
                    print("Chat has ended. Not processing chat response.")
                    return
                }
                
                print("Chat response text: \(responseText)")
                let assistantMessage = ChatMessage(role: "assistant", content: responseText)
                self.currentMessage = responseText
                self.recordingState = ""
                
                AzureSpeechService.shared.synthesizeSpeech(text: responseText) { audioURL in
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
    /*
    func saveAudioData(_ audioData: Data, isUser: Bool, content: String) {
        guard let memoryCardId = memoryCardId else { return }
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
     */
    func saveAudioData(_ audioData: Data, isUser: Bool, content: String) {
        guard let memoryCardUUID = memoryCardUUID else { return }
        let fileName = "\(memoryCardUUID.uuidString)_\(Date().timeIntervalSince1970)_\(isUser ? "user" : "bot").wav"
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (audioPlayer?.duration ?? 0)) {
                completion()
            }
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
            isPlaying = false
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
*/


