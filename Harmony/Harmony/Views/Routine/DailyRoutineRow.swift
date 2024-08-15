//
//  DailyRoutineRow.swift
//  Harmony
//
//  Created by 조다은 on 7/24/24.
//
/*
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
                Text(dailyRoutine.time.formattedTime)
                    .font(.pretendardMedium(size: 16))
                    .foregroundColor(Color.gray4)
                    .padding(.top, 5)
                
                Text(routine?.title ?? "")
                    .font(.pretendardSemiBold(size: 24))
                    .foregroundColor(Color.bl)
                    .lineSpacing(20 * 0.2)
                    .frame(width: 157, height: 68, alignment: .topLeading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray2, lineWidth: 1)
        )
    }
}

#Preview {
    DailyRoutineRow(dailyRoutine: DailyRoutine(
        id: 1,
        routineId: 1,
        groupId: 1,
        time: "2024-07-31T07:09:00.000Z",
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
*/

import SwiftUI

struct DailyRoutineRow: View {
    let dailyRoutine: DailyRoutine
    let routine: Routine?
    @State private var appear = false
    @State private var isPressed = false
    
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
                        .opacity(appear ? 1 : 0)
                        .scaleEffect(appear ? 1 : 0.5)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: appear)
                }
            }
            .padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 5) {
                Text(dailyRoutine.time.formattedTime)
                    .font(.pretendardMedium(size: 16))
                    .foregroundColor(Color.gray4)
                    .padding(.top, 5)
                
                Text(routine?.title ?? "")
                    .font(.pretendardSemiBold(size: 24))
                    .foregroundColor(Color.bl)
                    .lineSpacing(20 * 0.2)
                    .frame(width: 157, height: 68, alignment: .topLeading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray2, lineWidth: 1)
        )
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appear = true
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    isPressed = false
                }
            }
        }
    }
}

#Preview {
    DailyRoutineRow(dailyRoutine: DailyRoutine(
        id: 1,
        routineId: 1,
        groupId: 1,
        time: "2024-07-31T07:09:00.000Z",
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
