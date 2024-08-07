//
//  ChatModel.swift
//  Harmony
//
//  Created by 한범석 on 8/3/24.
//

import Foundation

// MARK: - 대화 기록, 음성 데이터 관련 응답

struct SaveChatHistoryResponse: Codable {
    let status: Bool
    let message: String
}

struct ChatHistoryResponse: Codable {
    let status: Bool
    let data: [MessageData]?
    let message: String
}

struct InitialPromptResponse: Codable {
    let status: Bool
    let data: String
    let message: String
}

struct MessageData: Codable {
    let id: Int
    let role: String
    let content: String
    let audioRecord: AudioRecordData?
}

struct AudioRecordData: Codable {
    let fileName: String
    let isUser: Bool
    let duration: TimeInterval
}

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let role: String
    let content: String
    var audioRecord: AudioRecord?
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
    var remoteURL: URL? // 새로 추가된 속성
    
    init(id: UUID = UUID(), fileName: String, isUser: Bool, duration: TimeInterval, remoteURL: URL? = nil) {
        self.id = id
        self.fileName = fileName
        self.isUser = isUser
        self.duration = duration
        self.remoteURL = remoteURL
    }
}


struct ChatHistory: Identifiable, Codable {
    let id: Int
    let date: Date
    let messages: [ChatMessage]
}


// MARK: - 음성 파일 작업 중 새로 추가한 모델링

struct ChatHistoryRequest: Codable {
    let groupId: Int
    let messages: [ChatMessageRequest]
}

struct ChatMessageRequest: Codable {
    let role: String
    let content: String
    let audioRecord: AudioRecordRequest?
}

struct AudioRecordRequest: Codable {
    let fileName: String
    let isUser: Bool
    let duration: TimeInterval
}
