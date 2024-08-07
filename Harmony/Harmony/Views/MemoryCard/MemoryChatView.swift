//
//  MemoryChatView.swift
//  Harmony
//
//  Created by 한범석 on 7/17/24.
//

/*
import SwiftUI

struct MemoryChatView: View {
    let messages: [ChatMessage]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages) { message in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(message.date)
                                .font(.footnote)
                                .foregroundStyle(.gray)
                            
                            HStack {
                                if message.sender == "모니" {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    Text(message.message)
                                        .padding()
                                        .background(.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    Spacer()
                                } else {
                                    Spacer()
                                    Text(message.message)
                                        .padding()
                                        .background(.green.opacity(0.6))
                                        .cornerRadius(10)
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
            }
            HStack {
                NavigationLink(destination: Text("이어서 대화하기 뷰")) {
                    Text("이어서 대화하기")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("대화 전체 보기")
        .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MemoryChatView(messages: dummyChatMessages)
}
*/

// MARK: - 1차 동작 버전
/*
import SwiftUI

struct MemoryChatView: View {
    var memoryCardId: Int
    @StateObject private var viewModel = MemoryCardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if viewModel.memoryCardDetail?.description.isEmpty ?? true {
                        Text("아직 대화를 시작하지 않았어요!")
                            .font(.title)
                            .foregroundStyle(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.chatHistory, id: \.id) { message in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(formatDate(message.date))
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                                
                                HStack {
                                    if message.role == "assistant" {
                                        Image(systemName: "person.crop.circle")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                        Text(message.content)
                                            .padding()
                                            .background(.gray.opacity(0.2))
                                            .cornerRadius(10)
                                        Spacer()
                                    } else {
                                        Spacer()
                                        Text(message.content)
                                            .padding()
                                            .background(.green.opacity(0.6))
                                            .cornerRadius(10)
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
            }
            HStack {
                NavigationLink(destination: MemoryCardRecordView(memoryCardId: memoryCardId)) {
                    Text(viewModel.memoryCardDetail?.description.isEmpty ?? true ? "모니와 대화 시작하기" : "이어서 대화하기")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("대화 전체 보기")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadMemoryCardDetail(id: memoryCardId)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}

#Preview {
    MemoryChatView(memoryCardId: 1)
}
*/

/*
import SwiftUI

struct MemoryChatView: View {
    var memoryCardId: Int
    var groupId: Int
    @StateObject private var viewModel: MemoryCardViewModel
    @StateObject private var aiViewModel: AzureAIViewModel
    @State private var showAudioPlayer = false
    @StateObject private var audioPlayer = AudioPlayer()
    
    init(memoryCardId: Int, groupId: Int) {
        self.memoryCardId = memoryCardId
        self.groupId = groupId
        _viewModel = StateObject(wrappedValue: MemoryCardViewModel())
        _aiViewModel = StateObject(wrappedValue: AzureAIViewModel(memoryCardId: memoryCardId, groupId: groupId))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if viewModel.chatHistory.isEmpty {
                            Text("아직 대화를 시작하지 않았어요!")
                                .font(.title)
                                .foregroundStyle(.gray)
                                .padding()
                        } else {
                            ForEach(viewModel.chatHistory) { message in
                                ChatBubble(message: message)
                            }
                        }
                    }
                    .padding(.top)
                }

                Button("음성 듣기") {
                    let audioURLs = viewModel.chatHistory.compactMap { $0.audioRecord?.fileName }.map { FileManager.getDocumentsDirectory().appendingPathComponent($0) }
                    audioPlayer.loadPlaylist(audioURLs)
                    showAudioPlayer = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()

                if showAudioPlayer {
                    AudioPlayerView(audioPlayer: audioPlayer)
                        .frame(height: 100)
                        .padding()
                }

                HStack {
                    NavigationLink(destination: MemoryCardRecordView(memoryCardId: memoryCardId, groupId: groupId, previousChatHistory: viewModel.chatHistory)) {
                        Text(viewModel.chatHistory.isEmpty ? "모니와 대화 시작하기" : "이어서 대화하기")
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("대화 전체 보기")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadMemoryCardDetail(id: memoryCardId)
                viewModel.loadChatHistory(for: memoryCardId)
            }
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == "user" {
                Spacer()
                Text(message.content)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            } else {
                Text(message.content)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

#Preview {
    MemoryChatView(memoryCardId: 1, groupId: 1)
}
*/


