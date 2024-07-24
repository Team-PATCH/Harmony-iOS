//
//  RoutineDetailView.swift
//  Harmony
//
//  Created by 조다은 on 7/24/24.
//

import SwiftUI

struct RoutineDetailView: View {
    let dailyRoutine: DailyRoutine
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RoutineViewModel

    var routine: Routine? {
        viewModel.routines.first(where: { $0.id == dailyRoutine.routineId })
    }

    var body: some View {
        VStack {
            Text("일과 알림")
                .font(.pretendardBold(size: 20))
                .bold()
                .padding(.top)

            if let routine = routine {
                ZStack {
                    Image("speech-bubble")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 285)
                        .padding()

                    VStack {
                        Text(dailyRoutine.time, style: .time)
                            .font(.pretendardMedium(size: 28))
                            .foregroundColor(.green)
                        Text(routine.title)
                            .font(.pretendardSemiBold(size: 36))
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
                        // 인증사진 남기기 액션
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
    RoutineDetailView(dailyRoutine: DailyRoutine(
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
    viewModel: RoutineViewModel()
    )
}
