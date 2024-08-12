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
            if viewModel.chatMessages.isEmpty {
                VStack {
                    Spacer()
                    Image("moni-wholebody")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    Text("아직 이 추억에 대해 대화를 나누지 않으셨네요.\n모니와 대화를 나눠보세요!😄")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray1)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16, pinnedViews: []) {
                        ForEach(viewModel.chatMessages) { message in
                            VStack {
                                if shouldDisplayDate(for: message) {
                                    HStack {
                                        Spacer()
                                        Text(formatDate(message.date))
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 12)
                                            .background(Capsule().fill(Color.gray2))
                                        Spacer()
                                    }
                                }
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
                                    .frame(maxWidth: .infinity, alignment: message.role == "user" ? .trailing : .leading)
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                    .padding(.top)
                }
                .background(Color.gray1)
            }
            
            if showAudioPlayer {
                AudioPlayerView(audioPlayer: audioPlayer)
                    .frame(height: 100)
                    .padding()
                    .background(Color.wh)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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
                
                Button(action: {
                    withAnimation {
                        showAudioPlayer.toggle()
                    }
                    if showAudioPlayer {
                        playAllAudio()
                    } else {
                        audioPlayer.pausePlayback() // pause 메서드 호출
                    }
                }) {
                    Text("음성 듣기")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray2)
                        .foregroundColor(.bl)
                        .cornerRadius(10)
                }
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
    
    private func shouldDisplayDate(for message: ChatMessage) -> Bool {
        // Implement logic to determine if date should be displayed
        // Example: Display date if the previous message was on a different day
        if let previousMessage = viewModel.chatMessages.last(where: { $0.date < message.date }) {
            return !Calendar.current.isDate(previousMessage.date, inSameDayAs: message.date)
        }
        return true
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 M월 d일"
        return dateFormatter.string(from: date)
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
        HStack {
            if message.role == "user" {
                Spacer(minLength: 0)
            }
            
            VStack(alignment: message.role == "user" ? .trailing : .leading, spacing: 4) {
                HStack {
                    if message.role == "assistant" {
                        Image("moni-avatar")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                    
                    Text(message.content)
                        .padding(10)
                        .background(message.role == "user" ? Color.subGreen : Color.wh)
                        .foregroundColor(message.role == "user" ? .bl : .bl)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(message.role == "user" ? Color.mainGreen.opacity(0.5) : Color.gray3, lineWidth: 1)
                        )
                }
                
                if isSelected, let audioRecord = message.audioRecord, let url = URL(string: audioRecord.fileName) {
                    Button(action: {
                        audioPlayer.loadPlaylist([url])
                        audioPlayer.playPause()
                    }) {
                        Label(audioPlayer.isPlaying ? "일시정지" : "음성 듣기", systemImage: audioPlayer.isPlaying ? "pause.circle" : "play.circle")
                    }
                    .foregroundColor(.mainGreen)
                    .transition(.scale)
                }
            }
            
            if message.role == "assistant" {
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 4)
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
                // 로그 추가
                for message in messages {
                    print("Message role: \(message.role), content: \(message.content)")
                }
            })
            .store(in: &cancellables)
    }
}

