//
//  MemoryCardRecordView.swift
//  Harmony
//
//  Created by 한범석 on 7/23/24.
//

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
                        startRecording()
                    } else {
                        stopRecording()
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
    
    func startRecording() {
        // STT, TTS, and Azure OpenAI API integration logic
        chatBotMessage = "다은이를 분만실에서 처음 봤을 때 어떤 느낌이 들었나요?"
        // 여기에 STT 및 TTS 시작 로직을 추가
    }
    
    func stopRecording() {
        // Stop STT and TTS logic
        chatBotMessage = "대화가 종료되었습니다."
        // 여기에 STT 및 TTS 종료 로직을 추가
    }
}

#Preview {
    MemoryCardRecordView(memoryCardId: 1)
}


