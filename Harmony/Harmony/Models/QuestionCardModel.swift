//
//  QuestionCardModel.swift
//  Harmony
//
//  Created by Ji Hye PARK on 7/23/24.
//

import Foundation

// 사용자 정의 DateFormatter 생성
extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

struct Question: Identifiable, Codable {
    let id: Int
    let groupId: Int
    let question: String
    var answer: String?
    let createdAt: Date
    var answeredAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "questionId"
        case groupId, question, answer, createdAt, answeredAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        groupId = try container.decode(Int.self, forKey: .groupId)
        question = try container.decode(String.self, forKey: .question)
        answer = try container.decodeIfPresent(String.self, forKey: .answer)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        if let date = DateFormatter.iso8601Full.date(from: createdAtString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "날짜 문자열이 형식과 일치하지 않습니다.")
        }
        
        if let answeredAtString = try container.decodeIfPresent(String.self, forKey: .answeredAt) {
            answeredAt = DateFormatter.iso8601Full.date(from: answeredAtString)
        } else {
            answeredAt = nil
        }
    }
}

struct ProvideQuestion: Identifiable, Codable {
    let id: Int
    let question: String
}

struct Comment: Identifiable, Codable {
    let id: Int
    let questionId: Int
    let groupId: Int
    let authorId: String
    let content: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "commentId"
        case questionId, groupId, authorId, content, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        questionId = try container.decode(Int.self, forKey: .questionId)
        groupId = try container.decode(Int.self, forKey: .groupId)
        authorId = try container.decode(String.self, forKey: .authorId)
        content = try container.decode(String.self, forKey: .content)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        if let date = DateFormatter.iso8601Full.date(from: createdAtString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "날짜 문자열이 형식과 일치하지 않습니다.")
        }
    }
}
