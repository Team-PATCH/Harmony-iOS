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

struct DailyRoutine: Identifiable, Codable {
    var id: Int
    var routineId: Int
    var groupId: Int
    var time: String
    var completedPhoto: String?
    var completedTime: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "dailyId"
        case routineId, groupId, time, completedPhoto, completedTime
    }
}

struct RoutineReaction: Identifiable, Codable {
    var id: Int
    var dailyId: Int
    var routineId: Int
    var groupId: Int
    var authorId: String
    var photo: URL?
    var comment: String
    
    enum CodingKeys: String, CodingKey {
        case id = "rrId"
        case dailyId, routineId, groupId, authorId, photo, comment
    }
}
