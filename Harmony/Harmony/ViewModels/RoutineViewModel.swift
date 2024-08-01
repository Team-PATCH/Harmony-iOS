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

    func addReactionToRoutine(to dailyRoutine: DailyRoutine, content: String) async {
        let parameters: [String: Any] = [
            "routineId": dailyRoutine.routineId,
            "groupId": dailyRoutine.groupId,
            "authorId": "test@user.com",
            "comment": content
        ]

        do {
            let newReaction = try await RoutineService.shared.addReaction(dailyId: dailyRoutine.id, parameters: parameters)
            DispatchQueue.main.async {
                self.routineReactions.append(newReaction)
            }
        } catch {
            print("Error adding reaction: \(error)")
        }
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
    
    func proveDailyRoutine(dailyRoutine: DailyRoutine, image: UIImage) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        do {
            let updatedRoutine = try await RoutineService.shared.proveDailyRoutine(dailyId: dailyRoutine.id, imageData: imageData)
            DispatchQueue.main.async {
                if let index = self.dailyRoutines.firstIndex(where: { $0.id == dailyRoutine.id }) {
                    self.dailyRoutines[index] = updatedRoutine
                }
            }
        } catch {
            throw error
        }
    }
    
    func updateDailyRoutine(dailyRoutine: DailyRoutine, with photo: Image) {
        if let index = dailyRoutines.firstIndex(where: { $0.id == dailyRoutine.id }) {
            dailyRoutines[index].completedTime = Date().description
        }
    }

    func deleteRoutine(_ routine: Routine) async throws {
        do {
            try await RoutineService.shared.deleteRoutine(routineId: routine.id)
            DispatchQueue.main.async {
                if let index = self.routines.firstIndex(where: { $0.id == routine.id }) {
                    self.routines.remove(at: index)
                }
                Task {
                    await self.fetchDailyRoutines()
                }
            }
        } catch {
            throw error
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
    
    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            
            if let hour = components.hour, let minute = components.minute {
                let period = hour < 12 ? "오전" : "오후"
                let hourString = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
                return String(format: "%@ %d시 %d분", period, hourString, minute)
            }
        }
        return self
    }
}
