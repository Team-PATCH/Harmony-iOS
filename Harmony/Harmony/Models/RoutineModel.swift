//
//  RoutineModel.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import Foundation

struct Routine: Identifiable, Codable {
    var id: Int
    var groupId: Int
    var title: String
    var days: Int
    var time: String
    
    enum CodingKeys: String, CodingKey {
        case id = "routineId"
        case groupId, title, days, time
    }
}

struct RoutineResponse: Codable {
    let status: Bool
    let data: [Routine]
    let message: String
}

struct DailyRoutine: Identifiable, Codable {
    var id: Int
    var routineId: Int
    var groupId: Int
    var time: String
    var completedPhoto: URL?
    var completedTime: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "dailyId"
        case routineId, groupId, time, completedPhoto, completedTime
    }
}

struct DailyRoutineResponse: Codable {
    let status: Bool
    let data: [DailyRoutine]
    let message: String
}

struct RoutineReaction: Identifiable, Codable {
    var id: Int
    var dailyId: Int
    var routineId: Int
    var groupId: Int
    var authorId: String
    var photo: URL?
    var comment: String
    var createdAt: Date
    var updatedAt: Date?
    var deletedAt: Date?
}
