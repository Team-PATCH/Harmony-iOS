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

    var body: some View {
        VStack {
            Text("일과 알림")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            if let routine = routine {
                if let completedTime = dailyRoutine.completedTime
//                if let completedPhoto = dailyRoutine.completedPhoto,
//                   let completedPhotoURL = URL(string: completedPhoto.path),
//                   let imageData = try? Data(contentsOf: completedPhotoURL),
//                   let uiImage = UIImage(data: imageData) 
                {
                    VStack {
                        Image(systemName: "kingfisher-1.jpg")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 393, height: 240)
                            .padding()

                        Text(routine.title)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.black)
                            .padding(.top)

                        Text(dailyRoutine.time, style: .time)
                            .font(.title3)
                            .foregroundColor(.green)
                            .padding(.top)

                        Spacer()

                        VStack(alignment: .leading) {
                            Text("댓글 2")
                                .font(.headline)
                                .foregroundColor(.gray)
                            RoutineCommentView(author: "손녀 조다은", comment: "이거... 비둘기가 아닌 거 같은데요...?", imageName: "granddaughter")
                            RoutineCommentView(author: "손녀 조다은", comment: "멋있어 보이는 새!!!", imageName: "granddaughter")
                        }
                        .padding()
                    }
                } else {
                    VStack {
                        ZStack {
                            Image("speech-bubble")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 285)
                                .padding()

                            VStack {
                                Text(dailyRoutine.time, style: .time)
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
    }
}

struct RoutineCommentView: View {
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

struct RoutineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = RoutineViewModel()
        let dailyRoutine = DailyRoutine(
            id: 1,
            routineId: 1,
            groupId: 1,
            time: Date(),
            completedPhoto: nil,
            completedTime: nil,
            createdAt: Date(),
            updatedAt: nil,
            deletedAt: nil
        )
        return RoutineDetailView(dailyRoutine: dailyRoutine, viewModel: viewModel)
    }
}
//
//#Preview {
//    RoutineDetailView(dailyRoutine: DailyRoutine(
//        id: 1,
//        routineId: 1,
//        groupId: 1,
//        time: Date(),
//        completedPhoto: nil,
//        completedTime: nil,
//        createdAt: Date(),
//        updatedAt: nil,
//        deletedAt: nil
//    ),
//    viewModel: RoutineViewModel()
//    )
//}
