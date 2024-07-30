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
    @State private var isSaving: Bool = false
    @State private var isShowingTimePicker: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RoutineViewModel

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    
                    Text("새로운 일과")
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
                        addRoutine()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("추가하기")
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
                DatePickerModal(time: $time)
                    .presentationDetents([.fraction(0.5)]) // 모달의 높이를 절반으로 설정
            }
        }
    }

    func addRoutine() {
        isSaving = true
        let days = selectedDays.enumerated().reduce(0) { $0 + ($1.element ? (1 << (6 - $1.offset)) : 0) }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timeString = formatter.string(from: time)

        let parameters: [String: Any] = [
            "groupId": 1,
            "title": title,
            "days": days,
            "time": timeString
        ]

        Task {
            do {
                let newRoutine = try await RoutineService.shared.createRoutine(parameters: parameters)
                viewModel.routines.append(newRoutine)
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Error adding routine: \(error)")
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

struct DatePickerModal: View {
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
    RoutineAddView(viewModel: RoutineViewModel())
}
