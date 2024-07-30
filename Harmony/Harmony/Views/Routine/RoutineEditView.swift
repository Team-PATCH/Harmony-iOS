//
//  RoutineEditView.swift
//  Harmony
//
//  Created by 조다은 on 7/30/24.
//

import SwiftUI

struct RoutineEditView: View {
    @State private var title: String
    @State private var selectedDays: [Bool]
    @State private var time: Date
    @State private var isSaving: Bool = false
    @State private var isShowingTimePicker: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RoutineViewModel
    var routine: Routine

    init(viewModel: RoutineViewModel, routine: Routine) {
        self.viewModel = viewModel
        self.routine = routine
        _title = State(initialValue: routine.title)
        _time = State(initialValue: Date()) // 시간을 적절히 변환해야 함
        _selectedDays = State(initialValue: routine.daysToBoolArray())
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    
                    Text("일과 수정")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }

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

                Button(action: {
                    isShowingTimePicker.toggle()
                }) {
                    HStack {
                        Text(formatTime(time))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                Spacer()

                if isSaving {
                    ProgressView()
                        .padding()
                } else {
                    Button(action: {
                        updateRoutine()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("수정하기")
                            .font(.headline)
                            .foregroundColor(title.isEmpty || !selectedDays.contains(true) ? .gray : .white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(title.isEmpty || !selectedDays.contains(true) ? Color(UIColor.systemGray4) : Color.green)
                            .cornerRadius(10)
                            .padding()
                    }
                    .disabled(title.isEmpty || !selectedDays.contains(true))
                }
            }
            .sheet(isPresented: $isShowingTimePicker) {
                EditDatePickerModal(time: $time)
                    .presentationDetents([.fraction(0.5)]) // 모달의 높이를 절반으로 설정
            }
        }
    }

    func updateRoutine() {
        isSaving = true
        let days = selectedDays.enumerated().reduce(0) { $0 + ($1.element ? (1 << (6 - $1.offset)) : 0) }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timeString = formatter.string(from: time)

        let parameters: [String: Any] = [
            "title": title,
            "days": days,
            "time": timeString
        ]

        Task {
            do {
                try await RoutineService.shared.updateRoutine(routineId: routine.id, parameters: parameters)
                await viewModel.fetchRoutines()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Error updating routine: \(error)")
                isSaving = false
            }
        }
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

extension Routine {
    func daysToBoolArray() -> [Bool] {
        let daysString = String(days, radix: 2).pad(with: "0", toLength: 7)
        return daysString.map { $0 == "1" }
    }
}

struct EditDatePickerModal: View {
    @Binding var time: Date
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("시간 선택", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                    .environment(\.locale, Locale(identifier: "ko_KR")) // DatePicker의 로케일 설정

                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("완료")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationBarTitle("시간 설정", displayMode: .inline)
        }
    }
}

#Preview {
    RoutineEditView(viewModel: RoutineViewModel(), routine: Routine(id: 1, groupId: 1, title: "아침 운동", days: 0b1111100, time: "Date()"))
}
