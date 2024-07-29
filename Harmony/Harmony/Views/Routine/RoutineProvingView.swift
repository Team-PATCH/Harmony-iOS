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
    
    var body: some View {
        VStack {
            if let routine = routine {
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
                
                VStack {
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
                                Text("이곳을 눌러 사진을 남겨보세요!")
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
                    
                    Text(routine.title)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.black)
                        .padding(.top)
                    
//                    Text(dailyRoutine.time, style: .time)
//                        .font(.title3)
//                        .foregroundColor(.green)
//                        .padding(.top)
                }
                .padding()
                
                Spacer()
                
                Button(action: {
//                    if let selectedImage = selectedImage, let photoURL = saveImageToDocumentsDirectory(image: selectedImage) {
//                        dailyRoutine.completedPhoto = photoURL
                        let selectedImage = Image(systemName: "kingfisher-1.jpg")
//                        dailyRoutine.completedTime = Date()
                        viewModel.updateDailyRoutine(dailyRoutine: dailyRoutine, with: selectedImage)
                        presentationMode.wrappedValue.dismiss()
                        print("인증 완료~!")
//                    }
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


//#Preview {
//    let viewModel = RoutineViewModel()
//    let dailyRoutine = DailyRoutine(
//        id: 1,
//        routineId: 1,
//        groupId: 1,
//        time: Date(),
//        completedPhoto: nil,
//        completedTime: nil,
//        createdAt: Date(),
//        updatedAt: nil,
//        deletedAt: nil
//    )
//    return RoutineProvingView(dailyRoutine: .constant(dailyRoutine), viewModel: viewModel)
//}
