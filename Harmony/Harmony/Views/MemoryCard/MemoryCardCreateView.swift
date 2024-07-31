//
//  MemoryCardCreateView.swift
//  Harmony
//
//  Created by 한범석 on 7/31/24.
//

import SwiftUI

struct MemoryCardCreateView: View {
    @Binding var isPresented: Bool
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var description = ""
    @State private var year = 2024
    @State private var isShowingYearPicker = false
    @State private var offset: CGFloat = 1000
    @State private var yearPickerPosition: CGPoint = .zero

    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }

    var isFormValid: Bool {
        selectedImage != nil && !description.isEmpty && year != 0
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if isShowingYearPicker {
                            withAnimation {
                                isShowingYearPicker = false
                            }
                        } else {
                            closeView()
                        }
                    }
                
                VStack {
                    HStack {
                        Text("추억 카드 만들기")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                        Button(action: closeView) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray3)
                        }
                        .padding(.leading, -20)
                    }
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
                                    isShowingYearPicker.toggle()
                                }
                            }) {
                                HStack {
                                    Text(numberFormatter.string(from: NSNumber(value: year)) ?? "")
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
                                        yearPickerPosition = geo.frame(in: .global).origin
                                    }
                                    return Color.clear
                                }
                            )
                        }
                        
                        Button(action: {
                            // 여기에 저장 로직 구현
                            closeView()
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
                
                if isShowingYearPicker {
                    YearPickerView(selectedYear: $year, isPresented: $isShowingYearPicker)
                        .position(x: yearPickerPosition.x + 230, y: yearPickerPosition.y - 205)
                        .transition(.asymmetric(insertion: .scale(scale: 0.1).combined(with: .opacity),
                                                removal: .scale(scale: 0.1).combined(with: .opacity)))
                        .animation(.spring(), value: isShowingYearPicker)
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
    }
    
    private func closeView() {
        offset = 1000
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

struct YearPickerView: View {
    @Binding var selectedYear: Int
    @Binding var isPresented: Bool
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }
    
    var body: some View {
        VStack {
            Picker("Year", selection: $selectedYear) {
                ForEach(1900...2025, id: \.self) { year in
                    Text(numberFormatter.string(from: NSNumber(value: year)) ?? "").tag(year)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            Button("Done") {
                withAnimation(.spring()) {
                    isPresented = false
                }
            }
            .padding()
        }
        .frame(width: 200, height: 250)
        .background(Color.wh)
        .cornerRadius(20)
        .overlay(
            Path { path in
                path.move(to: CGPoint(x: 160, y: 250))  // 오른쪽으로 이동
                path.addLine(to: CGPoint(x: 170, y: 270))  // 오른쪽으로 이동
                path.addLine(to: CGPoint(x: 180, y: 250))  // 오른쪽으로 이동
            }
            .fill(Color.wh)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            , alignment: .bottomLeading
        )
        .shadow(radius: 10)
    }
}


#Preview {
    MemoryCardCreateView(isPresented: .constant(true))
}
