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
                    Spacer()
                    
                    Text("댓글 남기기")
                        .font(.pretendardMedium(size: 18))
                        .foregroundColor(Color.bl)
                    
                    Spacer()
                    
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            .padding()
            
            Button(action: {
                showingCameraView.toggle()
            }) {
                ZStack {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 352, height: 195)
                            .clipped()
                            .cornerRadius(10)
                    } else {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 352, height: 195)
                            .background(Color.gray1)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray2, style: StrokeStyle(lineWidth: 2, dash: [2, 4]))
                            )
                        
                        Image("camera-icon")
                            .font(.largeTitle)
                    }
                }
            }
            .sheet(isPresented: $showingCameraView) {
                CameraView(selectedImage: $selectedImage)
            }
            
            CustomTextEditor(text: $newReaction, backgroundColor: UIColor(Color.gray1), placeholder: "댓글을 입력해 주세요.")
                .cornerRadius(10)
                .padding()
            
            Button(action: {
                if !newReaction.isEmpty {
                    Task {
                        await viewModel.addReactionToRoutine(
                            to: dailyRoutine,
                            content: newReaction,
                            image: selectedImage,
                            authorId: UserDefaultsManager.shared.getAlias() ?? "손녀 다우닝"
                        )
                        newReaction = ""
                        selectedImage = nil
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }) {
                Text("작성 완료")
                    .font(.pretendardSemiBold(size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                    .padding()
                    .background(Color.mainGreen)
                    .cornerRadius(5)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(height: 585)
        .background(Color.wh.edgesIgnoringSafeArea(.all))
        .cornerRadius(10, corners: .topLeft)
        .cornerRadius(10, corners: .topRight)
    }
}

struct RoutineReactionRow: View {
    let id: Int
    let author: String
    let comment: String
    let profilePhoto: String =  "https://saharmony.blob.core.windows.net/daily-routine-proving/daily-routine-proving/app-icon.png"
    let reactionPhoto: URL?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
//                AsyncImage(url: URL(string: profilePhoto)) { phase in
//                    if let image = phase.image {
//                        image
//                            .resizable()
//                            .frame(width: 40, height: 40)
//                            .clipShape(Circle())
//                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
//                            .padding(.trailing, 10)
//                        
//                    } else if phase.error != nil {
//                        Image("imageName")
//                            .resizable()
//                            .frame(width: 40, height: 40)
//                            .clipShape(Circle())
//                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
//                            .padding(.trailing, 10)
//                    }
//                }

                Image("\(id)")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .padding(.trailing, 7)
                
                Text(author)
                    .font(.pretendardMedium(size: 18))
                    .foregroundColor(.gray5)
                
                Spacer()
            }
            .padding(.leading, 20)
            
            HStack(alignment: .top) {
                AsyncImage(url: reactionPhoto) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .frame(width: 88, height: 88)
                            .scaledToFit()
                            .cornerRadius(5)
                            .padding(.trailing, 7)
                        
                    } else if phase.error != nil {
                        
                    }
                }
                .padding(.leading, 20)
                
                Text(comment)
                    .font(.pretendardMedium(size: 20))
            }
        }
        .padding(.vertical, 20)
        .frame(width: 353)
        .background(Color.wh)
        .overlay(
            Rectangle()
                .inset(by: 0.5)
                .stroke(Color.gray2, lineWidth: 1)
        )
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
