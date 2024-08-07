//
//  MemoryCardChatHistoryView.swift
//  Harmony
//
//  Created by 한범석 on 8/4/24.
//

import SwiftUI
import Combine

struct ChatHistoryView: View {
    let memoryCardId: Int
    let groupId: Int
    
    @StateObject private var viewModel: ChatHistoryViewModel
    @State private var selectedMessageId: UUID?
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var showAudioPlayer = false
    @Environment(\.presentationMode) var presentationMode
    @Binding var shouldRefreshSummary: Bool
    @ObservedObject var memoryCardViewModel: MemoryCardViewModel
    @State private var initialMessageCount: Int = 0
    
    
    init(memoryCardId: Int, groupId: Int, shouldRefreshSummary: Binding<Bool>, memoryCardViewModel: MemoryCardViewModel) {
        self.memoryCardId = memoryCardId
        self.groupId = groupId
        _viewModel = StateObject(wrappedValue: ChatHistoryViewModel(memoryCardId: memoryCardId))
        self._shouldRefreshSummary = shouldRefreshSummary
        self.memoryCardViewModel = memoryCardViewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 16) {
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
                .padding()
            }
            .background(Color.gray1)
            
            if showAudioPlayer {
                AudioPlayerView(audioPlayer: audioPlayer)
                    .frame(height: 100)
                    .padding()
                    .background(Color.wh)
            }
            
            HStack(spacing: 16) {
                NavigationLink(destination: MemoryCardRecordView(memoryCardId: memoryCardId, groupId: groupId, previousChatHistory: viewModel.chatMessages)) {
                    Text("다시 대화하기")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.mainGreen)
                        .foregroundColor(.wh)
                        .cornerRadius(10)
                }
                
                Button("음성 듣기") {
                    playAllAudio()
                    showAudioPlayer = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray2)
                .foregroundColor(.bl)
                .cornerRadius(10)
            }
            .padding()
            .background(Color.wh)
        }
        .navigationTitle("대화 기록")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadChatHistory()
            initialMessageCount = viewModel.chatMessages.count
        }
        .onDisappear {
            if viewModel.chatMessages.count > initialMessageCount {
                shouldRefreshSummary = true
                memoryCardViewModel.lastMessageId = viewModel.chatMessages.last?.id.hashValue
            }
        }
    }

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
        HStack(alignment: .top, spacing: 8) {
            if message.role != "user" {
//                Image("moni-avatar") // 모니 아바타 이미지
//                    .resizable()
//                    .frame(width: 40, height: 40)
//                    .clipShape(Circle())
            } else {
                Spacer()
            }
            
            VStack(alignment: message.role == "user" ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(10)
                    .background(message.role == "user" ? Color.mainGreen : Color.wh)
                    .foregroundColor(message.role == "user" ? .wh : .bl)
                    .cornerRadius(15)
                
                if isSelected, let audioRecord = message.audioRecord {
                    if let url = URL(string: audioRecord.fileName) {
                        Button(action: {
                            audioPlayer.loadPlaylist([url])
                            audioPlayer.playPause()
                        }) {
                            Label(audioPlayer.isPlaying ? "일시정지" : "음성 듣기", systemImage: audioPlayer.isPlaying ? "pause.circle" : "play.circle")
                        }
                        .foregroundColor(.mainGreen)
                        .transition(.scale)
                    } else {
                        Text("Invalid URL: \(audioRecord.fileName)")
                            .foregroundColor(.subRed)
                    }
                }
            }
            
            if message.role == "user" {
//                Image("user-avatar") // 사용자 아바타 이미지
//                    .resizable()
//                    .frame(width: 40, height: 40)
//                    .clipShape(Circle())
            } else {
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}


/*
// MARK: - 디자인 수정 전 최종
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
*/

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

