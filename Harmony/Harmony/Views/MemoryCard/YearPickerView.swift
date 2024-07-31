//
//  YearPickerView.swift
//  Harmony
//
//  Created by 한범석 on 7/31/24.
//

import SwiftUI

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
                ForEach(1900...2030, id: \.self) { year in
                    Text(numberFormatter.string(from: NSNumber(value: year)) ?? "").tag(year)
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
        .overlay(
            Path { path in
                path.move(to: CGPoint(x: 160, y: 250))
                path.addLine(to: CGPoint(x: 170, y: 270))
                path.addLine(to: CGPoint(x: 180, y: 250))
            }
            .fill(Color.wh)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            , alignment: .bottomTrailing
        )
        .shadow(radius: 10)
    }
}

//#Preview {
//    YearPickerView()
//}
