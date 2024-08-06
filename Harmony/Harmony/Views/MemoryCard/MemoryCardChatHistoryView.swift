//
//  MemoryCardChatHistoryView.swift
//  Harmony
//
//  Created by 한범석 on 8/4/24.
//


// MARK: - 동작 버전
/*
import SwiftUI

struct ChatHistoryView: View {
    let memoryCardId: Int
    @StateObject private var viewModel: ChatHistoryViewModel
    @State private var selectedMessageId: UUID?
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var showAudioPlayer = false
    
    init(memoryCardId: Int) {
        self.memoryCardId = memoryCardId
        _viewModel = StateObject(wrappedValue: ChatHistoryViewModel(memoryCardId: memoryCardId))
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.chatMessages) { message in
                    ChatMessageView(message: message, isSelected: selectedMessageId == message.id, audioPlayer: audioPlayer)
                        .onTapGesture {
                            withAnimation {
                                if selectedMessageId == message.id {
                                    selectedMessageId = nil
                                    audioPlayer.playPause()
                                } else {
                                    selectedMessageId = message.id
                                    if let audioRecord = message.audioRecord {
                                        let url = FileManager.getDocumentsDirectory().appendingPathComponent(audioRecord.fileName)
                                        audioPlayer.loadPlaylist([url])
                                    }
                                }
                            }
                        }
                }
            }
            
            HStack {
                NavigationLink(destination: MemoryCardRecordView(memoryCardId: memoryCardId, previousChatHistory: viewModel.chatMessages)) {
                    Text("이어서 대화하기")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button("음성 듣기") {
                    playAllAudio()
                    showAudioPlayer = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            
            if showAudioPlayer {
                AudioPlayerView(audioPlayer: audioPlayer)
                    .frame(height: 100)
                    .padding()
            }
        }
        .navigationTitle("대화 기록")
        .onAppear {
            viewModel.loadChatHistory()
        }
    }
    
    func playAllAudio() {
        let audioURLs = viewModel.chatMessages.compactMap { message -> URL? in
            guard let audioRecord = message.audioRecord else { return nil }
            return FileManager.getDocumentsDirectory().appendingPathComponent(audioRecord.fileName)
        }
        audioPlayer.loadPlaylist(audioURLs)
        audioPlayer.playPause()
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    let isSelected: Bool
    @ObservedObject var audioPlayer: AudioPlayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message.role == "user" ? "사용자" : "AI")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(message.content)
                .padding(10)
                .background(message.role == "user" ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            if isSelected, let audioRecord = message.audioRecord {
                Button(action: {
                    audioPlayer.playPause()
                }) {
                    Label(audioPlayer.isPlaying ? "일시정지" : "음성 듣기", systemImage: audioPlayer.isPlaying ? "pause.circle" : "play.circle")
                }
                .transition(.scale)
            }
        }
    }
}

class ChatHistoryViewModel: ObservableObject {
    let memoryCardId: Int
    @Published var chatMessages: [ChatMessage] = []
    
    init(memoryCardId: Int) {
        self.memoryCardId = memoryCardId
    }
    
    func loadChatHistory() {
        let histories = ChatHistoryManager.shared.loadChatHistories()
        if let history = histories.first(where: { $0.id == memoryCardId }) {
            self.chatMessages = history.messages
        }
    }
}
*/

/*
// MARK: - 0805
import SwiftUI
import Combine

struct ChatHistoryView: View {
    let memoryCardId: Int
    let groupId: Int
    @StateObject private var viewModel: ChatHistoryViewModel
    @State private var selectedMessageId: UUID?
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var showAudioPlayer = false
    
    init(memoryCardId: Int, groupId: Int) {
        self.memoryCardId = memoryCardId
        self.groupId = groupId
        _viewModel = StateObject(wrappedValue: ChatHistoryViewModel(memoryCardId: memoryCardId))
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.chatMessages) { message in
                    ChatMessageView(message: message, isSelected: selectedMessageId == message.id, audioPlayer: audioPlayer)
                        .onTapGesture {
                            withAnimation {
                                if selectedMessageId == message.id {
                                    selectedMessageId = nil
                                    audioPlayer.playPause()
                                } else {
                                    selectedMessageId = message.id
                                    if let audioRecord = message.audioRecord {
                                        let url = FileManager.getDocumentsDirectory().appendingPathComponent(audioRecord.fileName)
                                        audioPlayer.loadPlaylist([url])
                                    }
                                }
                            }
                        }
                }
            }
            
            HStack {
                NavigationLink(destination: MemoryCardRecordView(memoryCardId: memoryCardId, groupId: groupId, previousChatHistory: viewModel.chatMessages)) {
                    Text("이어서 대화하기")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button("음성 듣기") {
                    playAllAudio()
                    showAudioPlayer = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            
            if showAudioPlayer {
                AudioPlayerView(audioPlayer: audioPlayer)
                    .frame(height: 100)
                    .padding()
            }
        }
        .navigationTitle("대화 기록")
        .onAppear {
            viewModel.loadChatHistory()
        }
    }
    
    
//    func playAllAudio() {
//        let audioURLs = viewModel.chatMessages.compactMap { message -> URL? in
//            guard let audioRecord = message.audioRecord else { return nil }
//            return FileManager.getDocumentsDirectory().appendingPathComponent(audioRecord.fileName)
//        }
//        audioPlayer.loadPlaylist(audioURLs)
//        audioPlayer.playPause()
//    }
    
//    func playAllAudio() {
//        let audioURLs = viewModel.chatMessages.compactMap { $0.audioRecord?.remoteURL }
//        audioPlayer.loadPlaylist(audioURLs)
//        audioPlayer.playPause()
//    }
    // MARK: - 0805 로컬 음성 재생
//    func playAllAudio() {
//        let audioURLs = viewModel.chatMessages.compactMap { message -> URL? in
//            guard let audioRecord = message.audioRecord else { return nil }
//            return URL(string: "\(MemoryCardService.shared.baseURL)/audio/\(audioRecord.fileName)")
//        }
//        audioPlayer.loadPlaylist(audioURLs)
//        audioPlayer.playPause()
//    }
    func playAllAudio() {
        let audioURLs = viewModel.chatMessages.compactMap { $0.audioRecord?.remoteURL }
        audioPlayer.loadPlaylist(audioURLs)
        audioPlayer.playPause()
    }
}
*/


import SwiftUI
import Combine

struct ChatHistoryView: View {
    let memoryCardId: Int
    let groupId: Int
    @StateObject private var viewModel: ChatHistoryViewModel
    @State private var selectedMessageId: UUID?
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var showAudioPlayer = false
    
    init(memoryCardId: Int, groupId: Int) {
        self.memoryCardId = memoryCardId
        self.groupId = groupId
        _viewModel = StateObject(wrappedValue: ChatHistoryViewModel(memoryCardId: memoryCardId))
    }
    
    var body: some View {
        VStack {
//            List {
//                ForEach(viewModel.chatMessages) { message in
//                    ChatMessageView(message: message, isSelected: selectedMessageId == message.id, audioPlayer: audioPlayer)
//                        .onTapGesture {
//                            withAnimation {
//                                if selectedMessageId == message.id {
//                                    selectedMessageId = nil
//                                    audioPlayer.playPause()
//                                } else {
//                                    selectedMessageId = message.id
//                                    if let remoteURL = message.audioRecord?.remoteURL {
//                                        audioPlayer.loadPlaylist([remoteURL])
//                                        audioPlayer.playPause()
//                                    }
//                                }
//                            }
//                        }
//                }
//            }
            List {
                ForEach(viewModel.chatMessages) { message in
                    ChatMessageView(message: message, isSelected: selectedMessageId == message.id, audioPlayer: audioPlayer)
                        .onTapGesture {
                            withAnimation {
                                if selectedMessageId == message.id {
                                    selectedMessageId = nil
                                    audioPlayer.playPause()
                                } else {
                                    selectedMessageId = message.id
                                    if let urlString = message.audioRecord?.fileName,
                                       let url = URL(string: urlString) {
                                        audioPlayer.loadPlaylist([url])
                                        audioPlayer.playPause()
                                    }
                                }
                            }
                        }
                }
            }
            
            HStack {
                NavigationLink(destination: MemoryCardRecordView(memoryCardId: memoryCardId, groupId: groupId, previousChatHistory: viewModel.chatMessages)) {
                    Text("이어서 대화하기")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button("음성 듣기") {
                    playAllAudio()
                    showAudioPlayer = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            
            if showAudioPlayer {
                AudioPlayerView(audioPlayer: audioPlayer)
                    .frame(height: 100)
                    .padding()
            }
        }
        .navigationTitle("대화 기록")
        .onAppear {
            viewModel.loadChatHistory()
        }
    }
    

//    func playAllAudio() {
//        let audioURLs = viewModel.chatMessages.compactMap { message -> URL? in
//            guard let audioRecord = message.audioRecord else { return nil }
//            return URL(string: audioRecord.fileName)
//        }
//        audioPlayer.loadPlaylist(audioURLs)
//        audioPlayer.playPause()
//    }
    
    func playAllAudio() {
        let audioURLs = viewModel.chatMessages.compactMap { message -> URL? in
            guard let urlString = message.audioRecord?.fileName else { return nil }
            return URL(string: urlString)
        }
        audioPlayer.loadPlaylist(audioURLs)
        audioPlayer.playPause()
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    let isSelected: Bool
    @ObservedObject var audioPlayer: AudioPlayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message.role == "user" ? "사용자" : "모니")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(message.content)
                .padding(10)
                .background(message.role == "user" ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(10)
            
//            if isSelected, let audioRecord = message.audioRecord {
//                Button(action: {
//                    audioPlayer.playPause()
//                }) {
//                    Label(audioPlayer.isPlaying ? "일시정지" : "음성 듣기", systemImage: audioPlayer.isPlaying ? "pause.circle" : "play.circle")
//                }
//                .transition(.scale)
//            }
            if isSelected, let audioRecord = message.audioRecord {
                if let url = URL(string: audioRecord.fileName) {
                    Button(action: {
                        audioPlayer.loadPlaylist([url])
                        audioPlayer.playPause()
                    }) {
                        Label(audioPlayer.isPlaying ? "일시정지" : "음성 듣기", systemImage: audioPlayer.isPlaying ? "pause.circle" : "play.circle")
                    }
                    .transition(.scale)
                } else {
                    Text("Invalid URL: \(audioRecord.fileName)")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

class ChatHistoryViewModel: ObservableObject {
    let memoryCardId: Int
    @Published var chatMessages: [ChatMessage] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(memoryCardId: Int) {
        self.memoryCardId = memoryCardId
    }
    
    func loadChatHistory() {
        MemoryCardService.shared.getChatHistory(mcId: memoryCardId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Failed to load chat history: \(error)")
                }
            }, receiveValue: { [weak self] messages in
                self?.chatMessages = messages
            })
            .store(in: &cancellables)
    }
}

