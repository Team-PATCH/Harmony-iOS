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
    @State private var isLoading = true
    @State private var isTyping = false
    @State private var displayedText = ""
    @State private var chatbotImageOffset: CGFloat = 0
    @State private var buttonOffset: CGFloat = 0
    @State private var moniImage = "moni-talk"
    @State private var showText = false
    @State private var showManualStopButton = false

    
    init(memoryCardId: Int, groupId: Int, previousChatHistory: [ChatMessage]) {
        self.memoryCardId = memoryCardId
        self.groupId = groupId
        self.previousChatHistory = previousChatHistory
        _viewModel = StateObject(wrappedValue: MemoryCardViewModel())
        _aiViewModel = StateObject(wrappedValue: AzureAIViewModel(chatMessages: previousChatHistory, memoryCardId: memoryCardId, groupId: groupId))
    }
    
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
//                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
//                         Image(systemName: "xmark")
//                             .foregroundColor(.black)
                    }
                }
                
                
                ZStack {
                    Color.gray1
                    
                    VStack {
                        if let card = viewModel.memoryCard, !card.image.isEmpty {
                            KFImage(URL(string: card.image))
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: 280)
                                .clipped()
                        } else {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                    }
                }
                .frame(height: 280)
                
                Spacer()
                
                VStack(alignment: .center, spacing: 10) {
                    if isTyping {
                        TypingAnimationView(text: $displayedText)
                            .font(.title3)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray3, lineWidth: 0.5)
                            )
                    } else if showText {
                        Text(aiViewModel.currentMessage)
                            .font(.title3)
                            .bold()
                            .lineLimit(5)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray3, lineWidth: 0.5)
                            )
                    }
                }
                .padding(.top, 5)
                .frame(height: 115)
                .animation(.easeInOut, value: isTyping)
                
                Spacer()
                    .frame(height: 30)
                
                VStack {
                    ZStack {
                        if aiViewModel.isRecording {
                            WaveFormView(amplitude: $aiViewModel.amplitude)
                                .frame(height: 50)
                                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                        }
                        
                        Image(moniImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
//                            .animation(.easeInOut, value: moniImage)
                    }
                    
                }
                if aiViewModel.isRecording {
                    HStack {
                        Text("목소리를 듣는 중이에요")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Button(action: {
                            aiViewModel.stopRecordingAndSendData()
                            showManualStopButton = false
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.mainGreen)
                                .font(.system(size: 24))
                        }
                        .opacity(showManualStopButton ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: showManualStopButton)
                    }
                } else if aiViewModel.isProcessing {
                    Text("모니가 답변을 생각하고 있어요")
                        .font(.headline)
                        .foregroundColor(.gray)
                } else if aiViewModel.isSpeaking {
                    Text("모니가 답변 중이에요")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                Spacer(minLength: 20)
                
                VStack {
                    Button(action: {
                        if !isConversationStarted {
                            isConversationStarted = true
                            aiViewModel.startRecording()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                chatbotImageOffset = -50
                                buttonOffset = 50
                                moniImage = "moni-face"
//                                showManualStopButton = true
                            }
                        } else {
                            aiViewModel.endConversation()
                            viewModel.updateSummaryAfterChat(for: memoryCardId)
                            isConversationStarted = false
                            withAnimation(.easeInOut(duration: 0.3)) {
                                chatbotImageOffset = 0
                                buttonOffset = 0
                                moniImage = "moni-happy"
//                                showManualStopButton = false
                            }
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
                    .padding(.bottom, 20)
                }
                .background(Color.white)
            }
            .onAppear {
                viewModel.loadMemoryCardDetail(id: memoryCardId)
                if aiViewModel.chatHistory.isEmpty {
                    aiViewModel.loadInitialPrompt(for: memoryCardId)
                } else {
                    let newPrompt = "다시 \(viewModel.memoryCard?.title ?? "이 추억")에 대한 대화를 시작해볼까요?"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        aiViewModel.setInitialPrompt(newPrompt)
                    }
                }
                aiViewModel.loadInitialChatHistory()
                aiViewModel.viewAppeared()
            }
            .onChange(of: viewModel.initialPrompt) { newPrompt in
                if !newPrompt.isEmpty {
                    startTypingAnimation(text: newPrompt)
                    aiViewModel.setInitialPrompt(newPrompt)
                }
            }
            .onChange(of: aiViewModel.currentMessage) { newMessage in
                if !newMessage.isEmpty && !isTyping {
                    startTypingAnimation(text: newMessage)
                }
            }
            .onChange(of: aiViewModel.isRecording) { isRecording in
                withAnimation {
                    moniImage = isRecording ? "moni-face" : "moni-talk"
                }
            }
            .onChange(of: aiViewModel.isSpeaking) { isSpeaking in
                withAnimation {
                    moniImage = isSpeaking ? "moni-talk" : "moni-face"
                }
            }
            .onChange(of: aiViewModel.isProcessing) { isProcessing in
                withAnimation {
                    moniImage = isProcessing ? "moni-face" : "moni-talk"
                }
            }
            .onChange(of: isConversationStarted) { isConversationStarted in
                if !isConversationStarted {
                    withAnimation {
                        moniImage = "moni-happy"
                    }
                }
            }
            .onChange(of: aiViewModel.isRecording) { newValue in
                if newValue && isConversationStarted {
                    showManualStopButton = true
                } else {
                    showManualStopButton = false
                }
            }
            .onDisappear {
                aiViewModel.stopConversationWithoutSaving()
            }
        }
        .navigationTitle(viewModel.memoryCard?.title ?? "모니와 대화하기")
    }
    
    private func startTypingAnimation(text: String) {
            guard !isTyping else { return }
            showText = false
            isTyping = true
            displayedText = ""
            
            for (index, character) in text.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                    displayedText += String(character)
                    if index == text.count - 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isTyping = false
                            showText = true
                            aiViewModel.setInitialPrompt(text)
                        }
                    }
                }
            }
        }
}


struct TypingAnimationView: View {
    @Binding var text: String
    @State private var cursorVisible = false
    
    var body: some View {
        HStack {
            Text(text)
            if cursorVisible {
                Text("|")
                    .opacity(0.7)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.6).repeatForever()) {
                cursorVisible.toggle()
            }
        }
    }
}


struct LoadingAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 20, height: 20)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}


#Preview {
    MemoryCardRecordView(
        memoryCardId: 32,
        groupId: 1,
        previousChatHistory: [
            ChatMessage(role: "system", content: "You are a helpful assistant."),
            ChatMessage(role: "user", content: "Hello!"),
            ChatMessage(role: "assistant", content: "Hello! How can I help you today?")
        ]
    )
}
