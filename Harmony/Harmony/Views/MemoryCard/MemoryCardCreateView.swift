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
    @State private var yearPickerOffset: CGSize = .zero

    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }
    
    
    var isFormValid: Bool {
        selectedImage != nil && !description.isEmpty && year != 0
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if isShowingYearPicker {
                        isShowingYearPicker = false
                    } else {
                        closeView()
                    }
                }
            
            VStack {
                HStack {
                    Text("추억 카드 만들기")
                        .font(.headline)
                    Spacer()
                    Button(action: closeView) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray3)
                    }
                }
                .padding()
                
                VStack(spacing: 20) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(Color.gray1)
                                .frame(height: 200)
                                .cornerRadius(10)
                            
                            Image(systemName: "camera")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray3)
                        }
                        .onTapGesture {
                            isShowingImagePicker = true
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("어떤 추억인가요?")
                            .font(.subheadline)
                            .foregroundColor(.gray5)
                        
                        TextField("예) 손녀가 태어난 날", text: $description)
                            .padding()
                            .background(Color.gray1)
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("언제 일어난 일인가요?")
                            .font(.subheadline)
                            .foregroundColor(.gray5)
                        
                        Button(action: {
                            withAnimation {
                                isShowingYearPicker.toggle()
                            }
                        }) {
                            HStack {
                                Text(numberFormatter.string(from: NSNumber(value: year)) ?? "\(year)")
                                    .foregroundColor(.bl)
                                Spacer()
                                Image(systemName: "calendar")
                                    .foregroundColor(.mainGreen)
                            }
                            .padding()
                            .background(Color.gray1)
                            .cornerRadius(10)
                        }
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
                    .transition(.asymmetric(insertion: .scale(scale: 0.1).combined(with: .opacity),
                                            removal: .scale(scale: 0.1).combined(with: .opacity)))
                    .animation(.spring(), value: isShowingYearPicker)
                    .offset(yearPickerOffset)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                offset = 0
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $selectedImage)
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
                ForEach(1900...2100, id: \.self) { year in
                    Text(numberFormatter.string(from: NSNumber(value: year)) ?? "\(year)").tag(year)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            Button("Done") {
                isPresented = false
            }
            .padding()
        }
        .frame(width: 200, height: 250)
        .background(Color.wh)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

#Preview {
    MemoryCardCreateView(isPresented: .constant(true))
}
