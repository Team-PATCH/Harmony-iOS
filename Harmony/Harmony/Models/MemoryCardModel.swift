//
//  MemoryCardModel.swift
//  Harmony
//
//  Created by 한범석 on 7/16/24.
//

import Foundation

struct MemoryCard: Identifiable, Codable {
    var id: Int
    var title: String
    var dateTime: String
    var image: String
    
    enum CodingKeys: String, CodingKey {
        case id = "memorycardId"
        case title, dateTime, image
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
    var tag: [String]
    var image: String
    var description: String
    var message: String
}


struct ChatMessage: Identifiable {
    let id = UUID()
    let date: String
    let sender: String
    let message: String
}

let dummyChatMessages = [
    ChatMessage(date: "20XX년 5월 4일, 화요일", sender: "모니", message: "다은이를 분만실에서 처음 봤을 때 어떤 느낌이 들었나요?"),
    ChatMessage(date: "20XX년 5월 4일, 화요일", sender: "사용자", message: "어쩌구 저쩌구 더미 텍스트 어쩌구 저쩌구 더미 텍스트 어쩌구 저쩌구 더미"),
    ChatMessage(date: "20XX년 7월 9일, 화요일", sender: "모니", message: "다은이를 분만실에서 처음 봤을 때 어떤 느낌이 들었나요?"),
    ChatMessage(date: "20XX년 7월 9일, 화요일", sender: "사용자", message: "어쩌구 저쩌구 더미 텍스트 어쩌구 저쩌구 더미 텍스트 어쩌구 저쩌구 더미")
]


