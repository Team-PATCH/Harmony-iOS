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
        HStack(alignment: .center) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(dailyRoutine.completedTime != nil ? Color.mainGreen : Color.gray2, lineWidth: 2)
                    .frame(width: 64, height: 64)
                    .background(dailyRoutine.completedTime != nil ? Color.subGreen : Color.clear)
                    .cornerRadius(10)

                if dailyRoutine.completedTime != nil {
                    Image("completed-icon")
                }
            }
            .padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 5) {
                Text(dailyRoutine.time)
                    .font(.pretendardMedium(size: 16))
                    .foregroundColor(Color.gray4)
                    .padding(.top, 5)

                Text(routine?.title ?? "")
                    .font(.pretendardSemiBold(size: 20))
                    .foregroundColor(.black)
                    .lineSpacing(20 * 0.4)
                    .frame(width: 157, height: 68, alignment: .topLeading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray2, lineWidth:1)
          )
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
        title: "공원 산책 가서 비둘기 사진 찍기",
        days: 0b01111111,
        time: "Date()"
    ))
}
