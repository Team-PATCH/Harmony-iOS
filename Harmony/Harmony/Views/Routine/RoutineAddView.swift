//
//  RoutineAddView.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import SwiftUI

struct RoutineAddView: View {
    @State private var title: String = ""
    @State private var selectedDays: [Bool] = Array(repeating: false, count: 7)
    @State private var time: Date = Date()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RoutineViewModel

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("새로운 일과")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                Text("무슨 일과인가요?")
                    .font(.headline)
                    .padding(.horizontal)

                TextField("예) 아침 식사 먹기", text: $title)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                Text("무슨 요일마다 하나요?")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)

                HStack {
                    ForEach(0..<7, id: \.self) { index in
                        DayButton(day: index, isSelected: $selectedDays[index])
                    }
                }
                .padding(.horizontal)

                Text("몇 시로 설정할까요?")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)

                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding(.horizontal)

                Spacer()

                Button(action: {
                    addRoutine()
                }) {
                    Text("추가하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(title.isEmpty || !selectedDays.contains(true))
            }
        }
    }

    func addRoutine() {
        let days = selectedDays.enumerated().reduce(0) { $0 + ($1.element ? (1 << (6 - $1.offset)) : 0) }
        let newRoutine = Routine(
            id: viewModel.routines.count + 1,
            groupId: 1,
            title: title,
            photo: nil,
            days: days,
            time: time
        )
        viewModel.routines.append(newRoutine)
        viewModel.generateDailyRoutines()
        presentationMode.wrappedValue.dismiss()
    }
}

struct DayButton: View {
    let day: Int
    @Binding var isSelected: Bool

    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            Text(daySymbol(for: day))
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.green : Color(UIColor.systemGray5))
                .foregroundColor(.white)
                .cornerRadius(20)
        }
    }

    func daySymbol(for day: Int) -> String {
        switch day {
        case 0: return "월"
        case 1: return "화"
        case 2: return "수"
        case 3: return "목"
        case 4: return "금"
        case 5: return "토"
        case 6: return "일"
        default: return ""
        }
    }
}

#Preview {
    RoutineAddView(viewModel: RoutineViewModel())
}
