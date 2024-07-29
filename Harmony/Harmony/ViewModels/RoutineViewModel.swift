//
//  RoutineViewModel.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import Foundation
import Combine
import SwiftUI

final class RoutineViewModel: ObservableObject {
    @Published var routines: [Routine] = []
    @Published var dailyRoutines: [DailyRoutine] = []
    @Published var routineReactions: [RoutineReaction] = []
    @Published var currentDateString: String = ""
    @Published var currentDayString: String = ""
    private var cancellables = Set<AnyCancellable>()

    var completionRate: Double {
        guard !dailyRoutines.isEmpty else { return 0.0 }
        
        let completedCount = dailyRoutines.filter { $0.completedPhoto != nil }.count
        return Double(completedCount) / Double(dailyRoutines.count)
    }

    init() {
        updateCurrentDate()
        Task {
            await fetchRoutines()
            await fetchDailyRoutines()
        }
    }

    func updateCurrentDate() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        
        let today = Date()
        currentDateString = formatter.string(from: today)
        currentDayString = formatter.weekdaySymbols[Calendar.current.component(.weekday, from: today) - 1]
    }

    func fetchRoutines() async {
        do {
            routines = try await RoutineService.shared.fetchRoutines()
        } catch {
            print("Error fetching routines: \(error)")
        }
    }

    func fetchDailyRoutines() async {
        do {
            dailyRoutines = try await RoutineService.shared.fetchDailyRoutines()
        } catch {
            print("Error fetching daily routines: \(error)")
        }
    }

    func fetchRoutineReactions(dailyId: Int) async {
        do {
            routineReactions = try await RoutineService.shared.fetchRoutineReactions(dailyId: dailyId)
        } catch {
            print("Error fetching routine reactions: \(error)")
        }
    }

    func addReactionToRoutine(to dailyRoutine: DailyRoutine, content: String) {
        let newReaction = RoutineReaction(
            id: UUID().hashValue,
            dailyId: dailyRoutine.id,
            routineId: dailyRoutine.routineId,
            groupId: dailyRoutine.groupId,
            authorId: "손녀 조다은", // 이 값을 적절히 변경해주세요.
            photo: nil,
            comment: content,
            createdAt: Date(),
            updatedAt: nil,
            deletedAt: nil
        )
        routineReactions.append(newReaction)
    }

    func daysAsString(for routine: Routine) -> String {
        let daysArray = ["월", "화", "수", "목", "금", "토", "일"]
        var result = [String]()
        let daysString = String(routine.days, radix: 2).pad(with: "0", toLength: 7)
        for (index, day) in daysArray.enumerated() {
            if daysString[index] == "1" {
                result.append(day)
            }
        }
        return result.joined(separator: ", ")
    }
    
    func updateDailyRoutine(dailyRoutine: DailyRoutine, with photo: Image) {
        if let index = dailyRoutines.firstIndex(where: { $0.id == dailyRoutine.id }) {
//            dailyRoutines[index].completedPhoto = photo
            dailyRoutines[index].completedTime = Date()
        }
    }
}


extension String {
    func pad(with character: Character, toLength length: Int) -> String {
        let padding = length - count
        if padding > 0 {
            return String(repeating: character, count: padding) + self
        } else {
            return self
        }
    }

    subscript(i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}


let dummyRoutines = [
    Routine(id: 1, groupId: 1, title: "하율이 등원 시키기", photo: nil, days: 0b1111100, time: Date()), // 월화수목금
    Routine(id: 2, groupId: 1, title: "공원 산책가서 비둘기 사진 찍기", photo: nil, days: 0b1100000, time: Date()), // 월화
    Routine(id: 3, groupId: 1, title: "문화센터 서예 교실 가기", photo: URL(string: "https://example.com/photo2.jpg"), days: 0b0000011, time: Date()), // 주말
    Routine(id: 4, groupId: 1, title: "요리하기", photo: URL(string: "https://example.com/photo3.jpg"), days: 0b1000000, time: Date())  // 월
]
