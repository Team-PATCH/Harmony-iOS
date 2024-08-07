//
//  MemoryCardCreateView.swift
//  Harmony
//
//  Created by 한범석 on 7/31/24.
//

import SwiftUI

struct MemoryCardCreateView: View {
    @StateObject private var viewModel = MemoryCardViewModel()
    @Binding var isPresented: Bool
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var description = ""
    @State private var selectedDate = Date()
    @State private var isShowingDatePicker = false
    @State private var offset: CGFloat = 1000
    @State private var datePickerPosition: CGPoint = .zero
    @State private var datePickerOpacity: Double = 0

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }
    
    private var serverDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    var isFormValid: Bool {
        selectedImage != nil && !description.isEmpty
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if isShowingDatePicker {
                            withAnimation(.spring()) {
                                isShowingDatePicker = false
                            }
                        } else {
                            closeView()
                        }
                    }
                
                VStack {
                    Text("추억 카드 만들기")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    
                    VStack(spacing: 20) {
                        ZStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                                    .cornerRadius(10)
                            } else {
                                Rectangle()
                                    .fill(Color.gray1)
                                    .frame(height: 200)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                            .foregroundColor(Color.gray3)
                                    )
                                
                                Image(systemName: "camera")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray3)
                            }
                        }
                        .frame(height: 200)
                        .onTapGesture {
                            isShowingImagePicker = true
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("어떤 추억인가요?")
                                .font(.subheadline)
                                .foregroundColor(.gray5)
                            
                            TextField("예) 손녀가 태어난 날", text: $description)
                                .padding()
                                .background(Color.gray1)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray2, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("언제 일어난 일인가요?")
                                .font(.subheadline)
                                .foregroundColor(.gray5)
                            
                            Button(action: {
                                withAnimation(.spring()) {
                                    isShowingDatePicker.toggle()
                                }
                            }) {
                                HStack {
                                    Text(dateFormatter.string(from: selectedDate))
                                        .foregroundColor(.bl)
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .foregroundColor(.mainGreen)
                                }
                                .padding()
                                .background(Color.gray1)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray2, lineWidth: 1)
                                )
                            }
                            .overlay(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        datePickerPosition = geo.frame(in: .global).origin
                                    }
                                    return Color.clear
                                }
                            )
                        }
                        
                        Button(action: {
                            // 여기에 저장 로직 구현
                            if let selectedImage = selectedImage {
                                viewModel.createMemoryCard(
                                    groupId: 1,
                                    title: description,
                                    date: selectedDate,
                                    image: selectedImage
                                ) { result in
                                    switch result {
                                        case .success(_):
                                            closeView()
                                        case .failure(let error):
                                            print("Error: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }) {
                            Text("추억 카드 보내기")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.mainGreen : Color.gray3)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!isFormValid)
                    }
                    .padding()
                }
                .background(Color.wh)
                .cornerRadius(20)
                .shadow(radius: 20)
                .padding()
                .offset(y: offset)
                .animation(.spring(), value: offset)
                
                if isShowingDatePicker {
                    CustomDatePickerView(selectedDate: $selectedDate, isPresented: $isShowingDatePicker)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .opacity(datePickerOpacity)
                        .animation(.spring(), value: datePickerOpacity)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    offset = 0
                }
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $selectedImage)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: isShowingDatePicker) { newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.1)) {
                datePickerOpacity = newValue ? 1 : 0
            }
        }
    }
    
    private func closeView() {
        offset = 1000
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}


#Preview {
    MemoryCardCreateView(isPresented: .constant(true))
}
