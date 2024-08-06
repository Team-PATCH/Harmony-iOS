//
//  RoutineDetailView.swift
//  Harmony
//
//  Created by 조다은 on 7/24/24.
//

import SwiftUI

struct RoutineDetailView: View {
    @State var dailyRoutine: DailyRoutine
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RoutineViewModel
    
    var routine: Routine? {
        viewModel.routines.first(where: { $0.id == dailyRoutine.routineId })
    }
    
    @State private var showingProvingView = false
    @State private var showingReactionView = false
    
    var body: some View {
        VStack(spacing: 0) {
            if let routine = routine {
                if let completedTime = dailyRoutine.completedTime, let completedPhoto = dailyRoutine.completedPhoto, let completedPhotoURL = URL(string: completedPhoto) {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image("back-icon")
                                    .foregroundColor(.clear)
                            }
                            Spacer()
                            Text("일과 인증")
                                .font(.pretendardBold(size: 20))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 60)
                        .background(Color.white)
                        
                        // 인증된 사진 섹션
                        AsyncImage(url: completedPhotoURL) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 393, height: 240)
                            } else if phase.error != nil {
                                Text("Failed to load image")
                                    .foregroundColor(.red)
                            } else {
                                ProgressView()
                                    .frame(width: 393, height: 240)
                            }
                        }
                        .background(Color.white)
                        
                        // Title and Time
                        VStack(spacing: 0) {
                            Text(routine.title)
                                .font(.pretendardBold(size: 24))
                            
                            Text(dailyRoutine.time.formattedTime)
                                .font(.pretendardMedium(size: 20))
                                .foregroundColor(Color.mainGreen)
                                .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 25)
                        .background(Color.wh)
                        
                        // 댓글 섹션
                        ScrollView {
                            VStack(alignment: .center, spacing: 10) {
                                HStack {
                                    Text("댓글 \(viewModel.routineReactions.filter { $0.dailyId == dailyRoutine.id }.count)")
                                        .font(.pretendardMedium(size: 18))
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                
                                ForEach(viewModel.routineReactions.filter { $0.dailyId == dailyRoutine.id }) { reaction in
                                    RoutineReactionRow(author: reaction.authorId, comment: reaction.comment, reactionPhoto: reaction.photo)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }
                    }
                    .background(Color.gray1.edgesIgnoringSafeArea(.all))
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                Button(action: {
                                    showingReactionView.toggle()
                                }) {
                                    Text("댓글 남기기")
                                        .font(.pretendardSemiBold(size: 22))
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(width: 201, height: 68)
                                        .background(Color.mainGreen)
                                        .cornerRadius(999)
                                }
                                .padding(10)
                                .sheet(isPresented: $showingReactionView) {
                                    RoutineReactionInputView(dailyRoutine: dailyRoutine, viewModel: viewModel)
                                }
                            }
                        }
                    )
                } else {
                    VStack {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image("back-icon")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            Text("일과 알림")
                                .font(.pretendardBold(size: 20))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 60)
                        .padding(.bottom, 15)
                        
                        ZStack {
                            Image("speech-bubble")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 285)
                            
                            VStack(spacing: 0) {
                                Text(dailyRoutine.time.formattedTime)
                                    .font(.pretendardMedium(size: 28))
                                    .foregroundColor(Color.mainGreen)
                                    .padding(.bottom, 25)
                                
                                Text(routine.title)
                                    .font(.pretendardSemiBold(size: 36))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(36 * 0.2)
                                    .frame(width: 235, height: 100, alignment: .center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        Image("moni-face")
                            .resizable()
                            .frame(width: 164, height: 136)
                            .padding(.top, 15)
                        
                        Spacer()
                        
                        VStack {
                            Button(action: {
                                showingProvingView.toggle()
                            }) {
                                Text("인증사진 남기러 가기")
                                    .font(.pretendardSemiBold(size: 24))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 68)
                                    .background(Color.mainGreen)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .fullScreenCover(isPresented: $showingProvingView) {
                                RoutineProvingView(dailyRoutine: $dailyRoutine, viewModel: viewModel)
                            }
                            
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("나중에 남기기")
                                    .font(.pretendardSemiBold(size: 24))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 68)
                                    .background(Color.bl)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom)
                    }
                }
            } else {
                Text("루틴 정보를 불러올 수 없습니다.")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchRoutineReactions(dailyId: dailyRoutine.id)
            }
        }
    }
}

#Preview {
    RoutineDetailView(dailyRoutine: DailyRoutine(
        id: 1,
        routineId: 1,
        groupId: 1,
        time: "Date()",
        completedPhoto: "https://saharmony.blob.core.windows.net/daily-routine-proving/daily-routine-proving/Rectangle 641722412176673.png",
        completedTime: "nil"
    ),
                      viewModel: RoutineViewModel()
    )
}
