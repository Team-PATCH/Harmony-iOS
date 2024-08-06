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

struct UserGroup: Codable {
    let userId: String
    let groupId: String
    let permissionId: String
    let alias: String
    let deviceToken: String
}

struct GroupCreationResponse: Codable {
    let group: Group
    let inviteUrl: String
    let vipInviteUrl: String
}

struct GroupJoinResponse: Codable {
    let message: String
    let group: Group
    let permission: String
}

struct OnboardingUpdateResponse: Codable {
    let message: String
    let userGroup: UserGroup
}
