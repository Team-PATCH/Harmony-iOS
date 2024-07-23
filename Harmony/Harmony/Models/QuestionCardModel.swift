//
//  QuestionCardModel.swift
//  Harmony
//
//  Created by Ji Hye PARK on 7/23/24.
//

import Foundation

struct Question: Identifiable, Codable {
    let id: Int
    let groupId: Int
    let question: String
    var answer: String?
    let createdAt: Date
    var answeredAt: Date?
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "questionId" // 서버의 questionId를 id로 매핑
        case groupId, question, answer, createdAt, answeredAt, updatedAt
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
}
