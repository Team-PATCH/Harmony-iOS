//
//  OnboardingModel.swift
//  Harmony
//
//  Created by 한수빈 on 8/1/24.
//

import Foundation

struct Group: Codable {
    let groupId: Int
    let name: String
    let inviteUrl: String?
    let vipInviteUrl: String?
    let updatedAt: String
    let createdAt: String
}

struct GroupCreationResponse: Codable {
    let groupId: Int
    let groupName: String
    let inviteUrl: String
    let vipInviteUrl: String
}

struct GroupJoinResponse: Codable {
    let message: String
    let group: Group
    let permission: String
}

struct UserGroup: Codable {
    let ugId: Int
    let userId: String
    let permissionId: String
    let groupId: Int
    let alias: String
    let deviceToken: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case ugId, userId, permissionId, groupId, alias, deviceToken, createdAt, updatedAt, deletedAt
        case user = "User"
    }
}

struct User: Codable {
    let nick: String
    let profile: String
}

struct OnboardingUpdateResponse: Codable {
    let message: String
    let userGroup: UserGroup
}
