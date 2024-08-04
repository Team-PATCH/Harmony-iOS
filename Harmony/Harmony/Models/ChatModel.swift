//
//  ChatModel.swift
//  Harmony
//
//  Created by 한범석 on 8/3/24.
//

import Foundation

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let role: String
    let content: String
    let audioRecord: AudioRecord?
    let date: Date
    
    init(id: UUID = UUID(), role: String, content: String, audioRecord: AudioRecord? = nil, date: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.audioRecord = audioRecord
        self.date = date
    }
}

struct AudioRecord: Codable, Identifiable {
    let id: UUID
    let fileName: String
    let isUser: Bool
    let duration: TimeInterval
    
    init(id: UUID = UUID(), fileName: String, isUser: Bool, duration: TimeInterval) {
        self.id = id
        self.fileName = fileName
        self.isUser = isUser
        self.duration = duration
    }
}


struct ChatHistory: Identifiable, Codable {
    let id: Int
    let date: Date
    let messages: [ChatMessage]
}


//struct ChatHistory: Identifiable, Codable {
//    let id: UUID
//    let date: Date
//    let messages: [ChatMessage]
//    
//    init(id: UUID = UUID(), date: Date = Date(), messages: [ChatMessage]) {
//        self.id = id
//        self.date = date
//        self.messages = messages
//    }
//}


