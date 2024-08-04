//
//  MemoryCardRecordView.swift
//  Harmony
//
//  Created by 한범석 on 7/23/24.
//

/*
import SwiftUI
import Kingfisher

struct MemoryCardRecordView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = MemoryCardViewModel() // ViewModel 객체
    @State private var isRecording = false
    @State private var chatBotMessage = "안녕하세요! 추억을 기록하러 오셨군요.\n 아래 버튼을 누르면 기록을 시작합니다."
    
    var memoryCardId: Int
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("다은이 태어난 날")
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
            .padding(.top)
            
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gray3)
            }
            
            ZStack {
                Color.gray1 // 이미지 영역 배경색
                
                VStack {
                    if let card = viewModel.memoryCard, !card.image.isEmpty {
                        KFImage(URL(string: card.image))
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.horizontal)
                    } else {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
            .frame(height: 250) // 이미지 영역 높이 지정
            
            VStack {
                Spacer()
                
                VStack(alignment: .center, spacing: 10) {
                    Text(chatBotMessage)
                        .font(.title3)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray3, lineWidth: 0.5)
                        )
                    HStack {
                        Spacer()
                        Image("moni-talk")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                        Spacer()
                    }
                }
                .padding(.bottom, 20)
                
                if isRecording {
                    WaveFormView()
                        .frame(height: 50)
                        .padding(.bottom, 20)
                }
                
                Spacer()
                
                Button(action: {
                    isRecording.toggle()
                    if isRecording {
                        viewModel.startRecording()
                    } else {
                        viewModel.stopRecording()
                    }
                }) {
                    HStack {
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        Text(isRecording ? "대화 종료" : "대화 시작")
                            .bold()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isRecording ? Color.red : Color.mainGreen)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
            }
            .background(Color.white) // 나머지 부분 배경색
        }
//        .background(Color.gray1.edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.loadMemoryCardDetail(id: memoryCardId)
        }
    }
}

#Preview {
    MemoryCardRecordView(memoryCardId: 1)
}
*/

// MARK: - 로직 합친 후, 1차 동작 버전
/*
import SwiftUI
import Kingfisher

struct MemoryCardRecordView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = MemoryCardViewModel()
    @StateObject private var aiViewModel = AzureAIViewModel()
    @State private var isRecording = false
    
    var memoryCardId: Int
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("다은이 태어난 날")
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
            .padding(.top)
            
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
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.horizontal)
                    } else {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
            .frame(height: 250)
            
            VStack {
                Spacer()
                
                VStack(alignment: .center, spacing: 10) {
                    Text(aiViewModel.currentMessage)
                        .font(.title3)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray3, lineWidth: 0.5)
                        )
                    HStack {
                        Spacer()
                        Image("moni-talk")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                        Spacer()
                    }
                }
                .padding(.bottom, 20)
                
                if aiViewModel.isRecording {
                    WaveFormView(amplitude: $aiViewModel.amplitude)
                        .frame(height: 50)
                        .padding(.bottom, 20)
                }
                
                Spacer()
                
                Button(action: {
                    aiViewModel.isRecording.toggle()
                    if aiViewModel.isRecording {
                        aiViewModel.startRecording()
                    } else {
                        aiViewModel.stopRecordingAndSendData()
                    }
                }) {
                    HStack {
                        Image(systemName: aiViewModel.isRecording ? "stop.fill" : "mic.fill")
                        Text(aiViewModel.isRecording ? "대화 종료" : "대화 시작")
                            .bold()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(aiViewModel.isRecording ? Color.red : Color.mainGreen)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .background(Color.white)
        }
        .onAppear {
            viewModel.loadMemoryCardDetail(id: memoryCardId)
            aiViewModel.viewAppeared()
        }
    }
}

#Preview {
    MemoryCardRecordView(memoryCardId: 1)
}
*/


import SwiftUI
import Kingfisher

struct MemoryCardRecordView: View {
    var memoryCardId: Int
    @StateObject private var viewModel: MemoryCardViewModel
    @StateObject private var aiViewModel: AzureAIViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isRecording = false
    
    init(memoryCardId: Int) {
        self.memoryCardId = memoryCardId
        _viewModel = StateObject(wrappedValue: MemoryCardViewModel())
        _aiViewModel = StateObject(wrappedValue: AzureAIViewModel(memoryCardId: memoryCardId))
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("다은이 태어난 날")
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
            .padding(.top)
            
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
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.horizontal)
                    } else {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
            .frame(height: 250)
            
            VStack {
                Spacer()
                
                VStack(alignment: .center, spacing: 10) {
                    Text(aiViewModel.currentMessage)
                        .font(.title3)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray3, lineWidth: 0.5)
                        )
                    HStack {
                        Spacer()
                        Image("moni-talk")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                        Spacer()
                    }
                }
                .padding(.bottom, 20)
                
                if aiViewModel.isRecording {
                    WaveFormView(amplitude: $aiViewModel.amplitude)
                        .frame(height: 50)
                        .padding(.bottom, 20)
                }
                
                Spacer()
                
                Button(action: {
                    if aiViewModel.isRecording {
                        aiViewModel.endConversation()
                    } else {
                        aiViewModel.startRecording()
                    }
                }) {
                    HStack {
                        Image(systemName: aiViewModel.isRecording ? "stop.fill" : "mic.fill")
                        Text(aiViewModel.isRecording ? "대화 종료" : "대화 시작")
                            .bold()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(aiViewModel.isRecording ? Color.red : Color.mainGreen)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 80) // 탭바 높이만큼 여백 추가
            }
            .background(Color.white)
        }
        .onAppear {
            viewModel.loadMemoryCardDetail(id: memoryCardId)
//            aiViewModel.memoryCardUUID = UUID(uuidString: "\(memoryCardId)") // memoryCardUUID 설정
            aiViewModel.viewAppeared()
//            aiViewModel.loadChatHistory(memoryCardId: memoryCardId) // 이 부분도 추가
        }
        .onDisappear {
            aiViewModel.endConversation()
        }
    }
}

#Preview {
    MemoryCardRecordView(memoryCardId: 1)
}


