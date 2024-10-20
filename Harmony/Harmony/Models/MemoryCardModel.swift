//
//  MemoryCardModel.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

import Foundation

struct MemoryCard: Identifiable, Codable, Equatable {
    var id: Int
    var title: String
    var dateTime: String
    var image: String
    var groupId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "memorycardId"
        case title, dateTime, image, groupId
    }

    // Equatable 프로토콜 준수하기 위해 == 연산자 정의
    static func == (lhs: MemoryCard, rhs: MemoryCard) -> Bool {
        return lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.dateTime == rhs.dateTime
            && lhs.image == rhs.image
            && lhs.groupId == rhs.groupId
    }
}

struct MemoryCardList: Codable {
    var status: Bool
    var data: [MemoryCard]?
    var message: String
}

struct MemoryCardDetail: Codable {
    var status: Bool
    var memorycardId: Int
    var title: String
    var dateTime: String
    var tags: [String]
    var image: String
    var description: String
    var message: String
    var groupId: Int?
}


struct ImageUploadResponse: Decodable {
    let imageUrl: String
}

// MARK: - 메모리 카드 생성 POST 응답


struct CreateMemoryCard: Codable {
    let status: Bool
    let data: MemoryCardData
    let message: String
    
}


struct MemoryCardData: Codable {
    let memorycardId: Int
    let title: String
    let dateTime: String
    let image: String
    let tags: [String]
}



// MARK: - 추억카드 요약 생성 관련 AI 응답


struct SummaryResponse: Codable {
    let status: Bool
    let data: SummaryData
    let message: String
}

struct SummaryData: Codable {
    let summary: String
    let lastMessageId: Int?
}



