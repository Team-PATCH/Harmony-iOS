//
//  FormatDate.swift
//  Harmony
//
//  Created by 한범석 on 7/17/24.
//

import Foundation

// MARK: - 날짜만 표시

func formattedDate(from dateTime: String) -> String {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime]
    if let date = dateFormatter.date(from: dateTime) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy년 M월 d일"
        return outputFormatter.string(from: date)
    }
    return dateTime
}

// MARK: - 시간 분 단위까지 표시

func formattedDateTime(from dateTime: String) -> String {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime]
    if let date = dateFormatter.date(from: dateTime) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return outputFormatter.string(from: date)
    }
    return dateTime
}
