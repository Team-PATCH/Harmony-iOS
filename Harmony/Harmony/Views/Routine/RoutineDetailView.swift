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
        VStack {
            if let routine = routine {
                if let completedTime = dailyRoutine.completedTime, let completedPhoto = dailyRoutine.completedPhoto, let completedPhotoURL = URL(string: completedPhoto) {
                    VStack {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            Text("일과 알림")
                                .font(.pretendardBold(size: 20))
                            Spacer()
                            Image(systemName: "arrow.left")
                                .foregroundColor(.clear)
                        }
                        
                        // 인증된 사진 섹션
                        AsyncImage(url: completedPhotoURL) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 393, height: 240)
                                    .padding()
                            } else if phase.error != nil {
                                Text("Failed to load image")
                                    .foregroundColor(.red)
                            } else {
                                ProgressView()
                                    .frame(width: 393, height: 240)
                            }
                        }
                        
                        Text(routine.title)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.black)
                            .padding(.top)
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("댓글 \(viewModel.routineReactions.filter { $0.dailyId == dailyRoutine.id }.count)")
                                .font(.headline)
                                .foregroundColor(.gray)
                            ForEach(viewModel.routineReactions.filter { $0.dailyId == dailyRoutine.id }) { reaction in
                                RoutineReactionRow(author: reaction.authorId, comment: reaction.comment, imageName: "granddaughter")
                            }
                        }
                        .padding()
                        
                        Spacer()
                    }
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    showingReactionView.toggle()
                                }) {
                                    Text("댓글 남기기")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                                .padding()
                                .sheet(isPresented: $showingReactionView) {
                                    RoutineReactionInputView(dailyRoutine: dailyRoutine, viewModel: viewModel)
                                        .presentationDetents([.medium, .fraction(0.4)])
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
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            Text("일과 인증")
                                .font(.pretendardBold(size: 20))
                            Spacer()
                            Image(systemName: "arrow.left")
                                .foregroundColor(.clear)
                        }
                        
                        ZStack {
                            Image("speech-bubble")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 285)
                                .padding()
                            
                            VStack {
                                Text("dailyRoutine.time")
                                    .font(.title)
                                    .foregroundColor(.green)
                                Text(routine.title)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                        }
                        
                        Spacer()
                        
                        Image("character")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding()
                        
                        Spacer()
                        
                        VStack {
                            Button(action: {
                                showingProvingView.toggle()
                            }) {
                                Text("인증사진 남기러 가기")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
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
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black)
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
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
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
        completedPhoto: nil,
        completedTime: nil
    ),
        viewModel: RoutineViewModel()
    )
}
