//
//  MemoryCardRecordView.swift
//  Harmony
//
//  Created by 한범석 on 7/23/24.
//

import SwiftUI
import Kingfisher

struct MemoryCardRecordView: View {
    var memoryCardId: Int
    var groupId: Int
    var previousChatHistory: [ChatMessage]
    @StateObject private var viewModel: MemoryCardViewModel
    @StateObject private var aiViewModel: AzureAIViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isConversationStarted = false

    
    init(memoryCardId: Int, groupId: Int, previousChatHistory: [ChatMessage]) {
        self.memoryCardId = memoryCardId
        self.groupId = groupId
        self.previousChatHistory = previousChatHistory
        _viewModel = StateObject(wrappedValue: MemoryCardViewModel())
        _aiViewModel = StateObject(wrappedValue: AzureAIViewModel(chatMessages: previousChatHistory, memoryCardId: memoryCardId, groupId: groupId))
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(viewModel.memoryCard?.title ?? "모니와 대화하기")
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
//            .padding(.top)
            
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gray3)
            }
            
            ZStack {
                Color.gray1
                
                VStack {
                    if let card = viewModel.memoryCard, !card.image.isEmpty {
                        KFImage(URL(string: card.image))
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .clipped()
                            .cornerRadius(10)
//                            .padding(.horizontal)
                    } else {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
            .frame(height: 200)
            
            ScrollView {
                Spacer()
                
                VStack(alignment: .center, spacing: 10) {
                    Text(aiViewModel.currentMessage)
                        .font(.headline)
                        .bold()
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray3, lineWidth: 0.5)
                        )
                    ZStack {
                        if aiViewModel.isRecording {
                            WaveFormView(amplitude: $aiViewModel.amplitude)
                                .frame(height: 50)
                        }
                        
                        Image("moni-talk")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 5)
                
                if aiViewModel.isRecording {
                    Text("목소리를 듣는 중이에요")
                        .foregroundColor(.gray)
                } else if aiViewModel.isSpeaking {
                    Text("모니가 답변을 생각하고 있어요")
                        .foregroundColor(.gray)
                }
                
                Spacer(minLength: 20)
                
                Button(action: {
                    if !isConversationStarted {
                        isConversationStarted = true
                        aiViewModel.startRecording()
                    } else {
                        aiViewModel.endConversation()
                        viewModel.updateSummaryAfterChat(for: memoryCardId)
                        isConversationStarted = false
                    }
                }) {
                    HStack {
                        Image(systemName: aiViewModel.isRecording ? "stop.fill" : "mic.fill")
                        Text(isConversationStarted ? "대화 종료" : "대화 시작")
                            .bold()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isConversationStarted ? Color.red : Color.mainGreen)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20) // 탭바 높이만큼 여백 추가
            }
            .background(Color.white)
        }
        .onAppear {
            viewModel.loadMemoryCardDetail(id: memoryCardId)
            if aiViewModel.chatHistory.isEmpty {
                aiViewModel.loadInitialPrompt(for: memoryCardId)
            }
            aiViewModel.loadInitialChatHistory()
            aiViewModel.viewAppeared()
        }
        .onChange(of: viewModel.initialPrompt) { newPrompt in
            if !newPrompt.isEmpty {
                aiViewModel.setInitialPrompt(newPrompt)
            }
        }
        .onDisappear {
            aiViewModel.stopConversationWithoutSaving()
        }
    }
}

#Preview {
    MemoryCardRecordView(
        memoryCardId: 1,
        groupId: 1,
        previousChatHistory: [
            ChatMessage(role: "system", content: "You are a helpful assistant."),
            ChatMessage(role: "user", content: "Hello!"),
            ChatMessage(role: "assistant", content: "Hello! How can I help you today?")
        ]
    )
}
