//
//  MemoryCardChatHistoryView.swift
//  Harmony
//
//  Created by 한범석 on 8/4/24.
//

import SwiftUI

struct ChatHistoryView: View {
    let memoryCardId: Int
    @StateObject private var viewModel: ChatHistoryViewModel
    
    init(memoryCardId: Int) {
        self.memoryCardId = memoryCardId
        _viewModel = StateObject(wrappedValue: ChatHistoryViewModel(memoryCardId: memoryCardId))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.chatMessages) { message in
                ChatMessageView(message: message)
            }
        }
        .navigationTitle("대화 기록")
        .onAppear {
            viewModel.loadChatHistory()
        }
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message.role == "user" ? "사용자" : "AI")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(message.content)
                .padding(10)
                .background(message.role == "user" ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            if let audioRecord = message.audioRecord {
                Button(action: {
                    // 오디오 재생 로직
                }) {
                    Label("음성 듣기", systemImage: "play.circle")
                }
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
