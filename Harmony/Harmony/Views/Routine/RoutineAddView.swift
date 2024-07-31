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
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Spacer()
                    
                    Text("새로운 일과")
                        .font(.pretendardBold(size: 20))
                        .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 20)
                }

                Divider()
                    .background(Color.gray3)
                
                VStack(alignment: .leading) {
                    Text("무슨 일과인가요?")
                        .font(.pretendardMedium(size: 18))
                        .padding(.horizontal, 5)
                    
                    TextField("예) 아침 식사 먹기", text: $title)
                        .padding()
                        .background(Color.gray1)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray2, lineWidth: 1)
                        )
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                
                VStack(alignment: .leading) {
                    Text("무슨 요일마다 하나요?")
                        .font(.pretendardMedium(size: 18))
                        .padding(.horizontal, 5)
                    
                    HStack {
                        ForEach(0..<7, id: \.self) { index in
                            DayButton(day: index, isSelected: $selectedDays[index])
                        }
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 20)

                VStack(alignment: .leading) {
                    Text("몇 시로 설정할까요?")
                        .font(.pretendardMedium(size: 18))
                        .padding(.horizontal, 5)
                    
                    Button(action: {
                        isShowingTimePicker.toggle()
                    }) {
                        HStack {
                            Image("clock-icon")
                                .foregroundColor(.gray)
                            Text(formatTime(time))
                                .font(.pretendardSemiBold(size: 20))
                                .foregroundColor(Color.bl)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray2, lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 20)

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
                            .font(.pretendardSemiBold(size: 24))
                            .foregroundColor(Color.wh)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .padding()
                            .background(title.isEmpty || !selectedDays.contains(true) ? Color.gray2 : Color.mainGreen)
                            .cornerRadius(10)
                            .padding()
                    }
                    .disabled(title.isEmpty || !selectedDays.contains(true))
                }
            }
            .sheet(isPresented: $isShowingTimePicker) {
                DatePickerModal(time: $time)
                    .presentationDetents([.fraction(0.5)])
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
                .font(.pretendardSemiBold(size: 18))
                .frame(width: 41, height: 48)
                .background(isSelected ? Color.subGreen : Color.gray1)
                .foregroundColor(Color.gray4)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray2, lineWidth: 1)
                )
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
                    .environment(\.locale, Locale(identifier: "ko_KR"))

                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("완료")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mainGreen)
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
