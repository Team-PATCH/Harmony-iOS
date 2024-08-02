//
//  RoutineReactionInputView.swift
//  Harmony
//
//  Created by 조다은 on 7/25/24.
//

import SwiftUI

struct RoutineReactionInputView: View {
    @State var dailyRoutine: DailyRoutine
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RoutineViewModel

    @State private var newReaction: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingCameraView = false

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding()
            
            Button(action: {
                            showingCameraView.toggle()
                        }) {
                            VStack {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 393, height: 240)
                                } else {
                                    Image(systemName: "camera")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("사진을 추가하려면 여기를 누르세요")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                            }
                            .frame(width: 393, height: 240)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                        }
                        .sheet(isPresented: $showingCameraView) {
                            CameraView(selectedImage: $selectedImage)
                        }

            CustomTextEditor(text: $newReaction, backgroundColor: UIColor(Color.gray2), placeholder: "댓글을 입력해 주세요.")
                .cornerRadius(10)
                .padding()
            
            Button(action: {
                if !newReaction.isEmpty {
                    Task {
                        await viewModel.addReactionToRoutine(to: dailyRoutine, content: newReaction)
                        newReaction = ""
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }) {
                Text("작성 완료")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(5)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .frame(height: 585)
        .background(Color.bl.edgesIgnoringSafeArea(.all))
        .cornerRadius(10, corners: .topLeft)
        .cornerRadius(10, corners: .topRight)
    }
}

struct RoutineReactionRow: View {
    let author: String
    let comment: String
    let imageName: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(imageName)
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                .padding(.trailing, 8)
            VStack(alignment: .leading) {
                Text(author)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(comment)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let viewModel = RoutineViewModel()
    let dailyRoutine = DailyRoutine(
        id: 1,
        routineId: 1,
        groupId: 1,
        time: "08:00:00",
        completedPhoto: nil,
        completedTime: nil
    )
    return RoutineReactionInputView(dailyRoutine: dailyRoutine, viewModel: viewModel)
}
