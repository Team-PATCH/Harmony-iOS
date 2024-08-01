//
//  YearMonthPickerView.swift
//  Harmony
//
//  Created by 한범석 on 7/31/24.
//

import SwiftUI

struct YearMonthPickerView: View {
    @Binding var currentDate: Date
    @Binding var isPresented: Bool
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    
    private let years = Array(1900...2030)
    private let months = Array(1...12)
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }
    
    init(currentDate: Binding<Date>, isPresented: Binding<Bool>) {
        _currentDate = currentDate
        _isPresented = isPresented
        let calendar = Calendar.current
        _selectedYear = State(initialValue: calendar.component(.year, from: currentDate.wrappedValue))
        _selectedMonth = State(initialValue: calendar.component(.month, from: currentDate.wrappedValue))
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text("\(numberFormatter.string(from: NSNumber(value: year)) ?? "")년").tag(year)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100)
                
                Picker("Month", selection: $selectedMonth) {
                    ForEach(months, id: \.self) { month in
                        Text("\(month)월").tag(month)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100)
            }
            
            HStack {
                Button("취소") {
                    isPresented = false
                }
                .foregroundColor(.gray5)
                
                Spacer()
                
                Button("확인") {
                    let calendar = Calendar.current
                    if let newDate = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) {
                        currentDate = newDate
                    }
                    isPresented = false
                }
                .foregroundColor(.mainGreen)
            }
            .padding(.top)
        }
        .padding()
        .background(Color.wh)
        .cornerRadius(15)
        .shadow(radius: 5)
        .frame(width: 250)
    }
}


//#Preview {
//    YearMonthPickerView()
//}
