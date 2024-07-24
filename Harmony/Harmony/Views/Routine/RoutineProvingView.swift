//
//  RoutineProvingView.swift
//  Harmony
//
//  Created by 조다은 on 7/24/24.
//

import SwiftUI

struct RoutineProvingView: View {
    let dailyRoutine: DailyRoutine
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RoutineViewModel

    var routine: Routine? {
        viewModel.routines.first(where: { $0.id == dailyRoutine.routineId })
    }

    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .foregroundColor(.black)
                }
                Spacer()
                Text("일과 인증")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "arrow.left") // Invisible button to center the title
                    .foregroundColor(.clear)
            }
            .padding()

            if let routine = routine {
                VStack {
                    Button(action: {
                        // 사진 선택 액션
                    }) {
                        VStack {
                            Image(systemName: "camera")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("이곳을 눌러 사진을 남겨보세요!")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        .frame(width: 300, height: 200)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .padding()
                    }

                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }

                    Text(routine.title)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.black)
                        .padding(.bottom, 0)

                    Text(dailyRoutine.time, style: .time)
                        .font(.title3)
                        .foregroundColor(.green)
                        .padding(.top, 5)
                }
                .padding()

                Spacer()

                Button(action: {
                    // 인증 완료 액션
                }) {
                    Text("인증 완료")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(selectedImage == nil)
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

#Preview {
    RoutineProvingView(dailyRoutine: DailyRoutine(
        id: 1,
        routineId: 1,
        groupId: 1,
        time: Date(),
        completedPhoto: nil,
        completedTime: nil,
        createdAt: Date(),
        updatedAt: nil,
        deletedAt: nil
    ),
    viewModel: RoutineViewModel())
}
