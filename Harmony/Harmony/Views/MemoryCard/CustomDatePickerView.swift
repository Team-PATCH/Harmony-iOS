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
    @State private var slideOffset: CGFloat = 0
    @State private var isSliding = false
    @State private var previousDate: Date = Date()

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
                    HStack {
                        Button(action: {
                            moveMonth(forward: false)
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.mainGreen)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                isShowingYearMonthPicker.toggle()
                            }
                        }) {
                            HStack {
                                Text(monthYearString(from: currentDate))
                                    .font(.headline)
                                    .foregroundColor(.mainGreen)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.mainGreen)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.gray1)
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            moveMonth(forward: true)
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.mainGreen)
                        }
                    }
                    .padding(.horizontal)

                    HStack {
                        ForEach(daysOfWeek, id: \.self) { day in
                            Text(day)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.gray5)
                        }
                    }
                    
                    ZStack {
                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(days(for: previousDate), id: \.self) { date in
                                if let date = date {
                                    DayCell(date: date, selectedDate: $selectedDate, currentDate: previousDate, month: previousDate)
                                } else {
                                    Text("")
                                        .frame(width: 30, height: 30)
                                }
                            }
                        }
                        .opacity(isSliding ? 1 : 0)
                        .offset(x: -slideOffset)

                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(days(for: currentDate), id: \.self) { date in
                                if let date = date {
                                    DayCell(date: date, selectedDate: $selectedDate, currentDate: currentDate, month: currentDate)
                                } else {
                                    Text("")
                                        .frame(width: 30, height: 30)
                                }
                            }
                        }
                        .opacity(isSliding ? 0 : 1)
                        .offset(x: isSliding ? slideOffset : 0)
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
                .background(Color.white)
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

    private func days(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth)
        else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let startDate = calendar.date(byAdding: .day, value: -(firstWeekday - 1), to: firstDayOfMonth)!
        
        var dates: [Date?] = []
        var currentDate = startDate
        
        for _ in 0..<42 {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }

    private func moveMonth(forward: Bool) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isSliding = true
            slideOffset = forward ? -UIScreen.main.bounds.width : UIScreen.main.bounds.width
        }
        
        previousDate = currentDate
        
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: forward ? 1 : -1, to: currentDate) {
            currentDate = newDate
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            slideOffset = 0
            isSliding = false
        }
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
