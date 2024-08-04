//
//  FormatDate.swift
//  Harmony
//
//  Created by 한범석 on 7/17/24.
//

import Foundation

// MARK: - 날짜만 표시
final class FormatManager {
    static let shared = FormatManager()
    private init() {}

    func formattedDate(from dateTime: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        if let date = dateFormatter.date(from: dateTime) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "ko_KR")
            outputFormatter.dateFormat = "yyyy년 M월 d일"
            return outputFormatter.string(from: date)
        }
        return dateTime
    }
    
    // MARK: - 시간 분 단위까지 표시
    func formattedDateTime(from dateTime: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = inputFormatter.date(from: dateTime) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "ko_KR")
            outputFormatter.dateFormat = "yyyy년 M월 d일 a h시 m분"
            return outputFormatter.string(from: date)
        }
        return dateTime
    }
}
