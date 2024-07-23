//
//  RoutineViewModel.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import Foundation
import Combine

class RoutineViewModel: ObservableObject {
    @Published var routines: [Routine] = dummyRoutines
    @Published var dailyRoutines: [DailyRoutine] = []
    @Published var routineReactions: [RoutineReaction] = []

    var completionRate: Double {
        let completedCount = dailyRoutines.filter { $0.completedPhoto != nil }.count
        return Double(completedCount) / Double(dailyRoutines.count)
    }
    
    init() {
        generateDailyRoutines()
    }

    func generateDailyRoutines() {
        let today = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today) - 1

        dailyRoutines = routines.compactMap { routine in
            if (routine.days & (1 << weekday)) != 0 {
                return DailyRoutine(
                    id: routine.id,
                    routineId: routine.id,
                    groupId: routine.groupId,
                    time: routine.time,
                    completedPhoto: nil,
                    completedTime: nil,
                    createdAt: today,
                    updatedAt: nil,
                    deletedAt: nil
                )
            }
            return nil
        }
    }

    func fetchRoutineReactions() {
        // Fetch routine reactions from your backend API and update the `routineReactions` array
    }

    func daysAsString(for routine: Routine) -> String {
        let daysArray = ["월", "화", "수", "목", "금", "토", "일"]
        var result = [String]()
        for (index, day) in daysArray.enumerated() {
            if (routine.days & (1 << index)) != 0 {
                result.append(day)
            }
        }
        return result.joined(separator: ", ")
    }
}

let dummyRoutines = [
    Routine(id: 1, groupId: 1, title: "공원 산책", photo: URL(string: "https://example.com/photo1.jpg"), day: 0b01111111, time: Date(), createdAt: Date(), updatedAt: nil, deletedAt: nil), // 월화수목금토일
    Routine(id: 3, groupId: 2, title: "요리하기", photo: URL(string: "https://example.com/photo3.jpg"), day: 0b00000001, time: Date(), createdAt: Date(), updatedAt: nil, deletedAt: nil)  // 월
]
