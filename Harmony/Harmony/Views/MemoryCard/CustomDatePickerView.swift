//
//  CustomDatePickerView.swift
//  Harmony
//
//  Created by 한범석 on 7/31/24.
//

import SwiftUI

struct CustomDatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    @State private var currentDate: Date = Date()
    @State private var isShowingYearMonthPicker = false
    @State private var yearMonthPickerOpacity: Double = 0

    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    
    private var month: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentDate))!
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isPresented = false
                    }
                
                VStack(spacing: 20) {
                    Button(action: {
                        withAnimation(.spring()) {
                            isShowingYearMonthPicker.toggle()
                        }
                    }) {
                        HStack {
                            Text(monthYearString(from: currentDate))
                                .font(.headline)
                                .foregroundColor(.black)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray5)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.gray1)
                        .cornerRadius(8)
                    }
                    .padding(.top)

                    HStack {
                        ForEach(daysOfWeek, id: \.self) { day in
                            Text(day)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.gray5)
                        }
                    }
                    
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(days(), id: \.self) { date in
                            if let date = date {
                                DayCell(date: date, selectedDate: $selectedDate, currentDate: currentDate, month: month)
                            } else {
                                Text("")
                                    .frame(width: 30, height: 30)  // 빈 셀도 같은 크기로 유지
                            }
                        }
                    }
                    
                    HStack {
                        Button("취소") {
                            isPresented = false
                        }
                        .foregroundColor(.gray5)
                        
                        Spacer()
                        
                        Button("확인") {
                            isPresented = false
                        }
                        .foregroundColor(.mainGreen)
                    }
                    .padding()
                }
                .padding()
                .background(Color.wh)
                .cornerRadius(20)
                .shadow(radius: 10)
                .frame(width: 350, height: 400)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.1), value: isPresented)

                if isShowingYearMonthPicker {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isShowingYearMonthPicker = false
                            }
                        }

                    YearMonthPickerView(currentDate: $currentDate, isPresented: $isShowingYearMonthPicker)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.1), value: isShowingYearMonthPicker)
                }
            }
        }
        .onChange(of: isShowingYearMonthPicker) { newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.1)) {
                yearMonthPickerOpacity = newValue ? 1 : 0
            }
        }
    }
    
    private func days() -> [Date?] {
        let calendar = Calendar.current
        
        // 현재 달의 첫 날과 마지막 날 구하기
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth)
        else {
            return []
        }
        
        // 첫 주의 시작일 구하기 (이전 달의 날짜 포함)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let startDate = calendar.date(byAdding: .day, value: -(firstWeekday - 1), to: firstDayOfMonth)!
        
        var dates: [Date?] = []
        var currentDate = startDate
        
        // 6주 동안의 날짜 생성 (이전 달과 다음 달의 날짜 포함)
        for _ in 0..<42 {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        print(dates.map { $0.map { String(describing: $0) } ?? "nil" }) // Debug print
        
        return dates
    }


    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }
}

struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date
    let currentDate: Date
    let month: Date
    
    var body: some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isCurrentMonth = calendar.isDate(date, equalTo: month, toGranularity: .month)
        
        Text("\(day)")
            .frame(width: 30, height: 30)  // 고정 크기 지정
            .background(isSelected ? Color.mainGreen : (isToday ? Color.gray2 : Color.clear))
            .foregroundColor(isSelected ? .white : (isToday ? .mainGreen : (isCurrentMonth ? .black : .gray)))
            .clipShape(Circle())
            .opacity(isCurrentMonth ? 1 : 0.3)
            .onTapGesture {
                if isCurrentMonth {
                    selectedDate = date
                }
            }
    }
}





//#Preview {
//    CustomDatePickerView()
//}
