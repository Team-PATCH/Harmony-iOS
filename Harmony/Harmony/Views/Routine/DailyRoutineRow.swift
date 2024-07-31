//
//  DailyRoutineRow.swift
//  Harmony
//
//  Created by 조다은 on 7/24/24.
//

import SwiftUI

struct DailyRoutineRow: View {
    let dailyRoutine: DailyRoutine
    let routine: Routine?

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(dailyRoutine.completedTime != nil ? Color.green : Color.gray, lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .background(dailyRoutine.completedTime != nil ? Color.green.opacity(0.2) : Color.clear)
                    .cornerRadius(5)

                if dailyRoutine.completedTime != nil {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.title)
                }
            }
            VStack(alignment: .leading) {
                Text(dailyRoutine.time)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(routine?.title ?? "")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .border(Color.gray2, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
        .cornerRadius(10)
    }
}

#Preview {
    DailyRoutineRow(dailyRoutine: DailyRoutine(
        id: 1,
        routineId: 1,
        groupId: 1,
        time: "오전 11시",
        completedPhoto: nil,
        completedTime: "Date()"
    ), routine: Routine(
        id: 1,
        groupId: 1,
        title: "공원 산책",
        days: 0b01111111,
        time: "Date()"
    ))
}
