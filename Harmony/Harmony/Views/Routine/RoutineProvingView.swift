//
//  RoutineProvingView.swift
//  Harmony
//
//  Created by 조다은 on 7/24/24.
//

import SwiftUI

struct RoutineProvingView: View {
    @Binding var dailyRoutine: DailyRoutine
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RoutineViewModel
    
    var routine: Routine? {
        viewModel.routines.first(where: { $0.id == dailyRoutine.routineId })
    }
    
    @State private var selectedImage: UIImage?
    @State private var showingCameraView = false
    @State private var isSaving = false
    
    var body: some View {
        VStack(spacing: 0) {
            if let routine = routine {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("back-icon")
                            .font(.title2)
                    }
                    Spacer()
                    Text("일과 인증")
                        .font(.pretendardBold(size: 20))
                    Spacer()
                    Image(systemName: "arrow.left")
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .frame(height: 40)
                
                VStack(spacing: 0) {
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
                                Image("camera-icon")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                    .padding(.top, 80)
                                ZStack(alignment: .center) {
                                    Image("speech-bubble-2")
                                    Text("이곳을 눌러 사진을 남겨보세요!")
                                        .font(.pretendardSemiBold(size: 22))
                                        .foregroundColor(Color.wh)
                                        .padding(.top, 20)
                                }
                            }
                        }
                        .frame(width: 393, height: 240)
                        .background(Color.gray1)
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $showingCameraView) {
                        CameraView(selectedImage: $selectedImage)
                    }
                    
                    Text(routine.title)
                        .font(.pretendardBold(size: 28))
                        .padding(.top, 40)
                    
                    Text(dailyRoutine.time.formattedTime)
                        .font(.pretendardMedium(size: 20))
                        .foregroundColor(Color.mainGreen)
                        .padding(.top, 10)
                }
                .padding()
                
                Spacer()
                
                if isSaving {
                    ProgressView()
                        .padding()
                } else {
                    Button(action: {
                        if let selectedImage = selectedImage {
                            Task {
                                isSaving = true
                                do {
                                    try await viewModel.proveDailyRoutine(dailyRoutine: dailyRoutine, image: selectedImage)
                                    presentationMode.wrappedValue.dismiss()
                                } catch {
                                    print("Error proving routine: \(error)")
                                }
                                isSaving = false
                            }
                        }
                    }) {
                        Text("인증 완료")
                            .font(.pretendardSemiBold(size: 24))
                            .foregroundColor(Color.wh)
                            .frame(maxWidth: .infinity)
                            .frame(height: 68)
                            .background(selectedImage == nil ? Color.gray2 : Color.mainGreen)
                            .cornerRadius(10)
                            .padding()
                    }
                    .disabled(selectedImage == nil)
                }
            } else {
                VStack {
                    Text("루틴 정보를 불러올 수 없습니다.")
                        .font(.pretendardSemiBold(size: 24))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.bl)
                        .padding()
                }
            }
        }
        .background(Color.wh.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    let viewModel = RoutineViewModel()
    let dailyRoutine = DailyRoutine(
        id: 1,
        routineId: 1,
        groupId: 1,
        time: "2024-07-30T00:00:00.000Z",
        completedPhoto: nil,
        completedTime: nil
    )
    return RoutineProvingView(dailyRoutine: .constant(dailyRoutine), viewModel: viewModel)
}
