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
    var photo: URL?
    var days: Int
    var time: Date
}

struct DailyRoutine: Identifiable, Codable {
    var id: Int
    var routineId: Int
    var groupId: Int
    var time: Date
    var completedPhoto: URL?
    var completedTime: Date?
    var createdAt: Date
    var updatedAt: Date?
    var deletedAt: Date?
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
