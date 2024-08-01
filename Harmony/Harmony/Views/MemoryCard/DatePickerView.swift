//
//  DatePickerView.swift
//  Harmony
//
//  Created by 한범석 on 7/31/24.
//

import SwiftUI

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
                .accentColor(.mainGreen)  // 선택된 날짜 색상 변경
            
            HStack {
                Button("취소") {
                    isPresented = false
                }
                .foregroundColor(.gray5)
                
                Spacer()
                
                Button("확인") {
                    isPresented = false
                }
                .foregroundColor(.mainGreen)  // 확인 버튼 색상 변경
            }
            .padding()
        }
        .padding()
        .background(Color.wh)
        .cornerRadius(20)
        .shadow(radius: 10)
        .frame(width: 300, height: 400)  // 크기 조정
    }
}



//#Preview {
//    DatePickerView()
//}
