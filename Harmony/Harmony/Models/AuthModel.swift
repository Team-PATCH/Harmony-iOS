//
//  AuthModel.swift
//  Harmony
//
//  Created by 한수빈 on 7/29/24.
//

import Foundation

struct AuthResponse: Codable {
    let message: String
    let user: AuthModel
    let token: String
}

struct AuthModel: Codable {
    var userId: String
    var nick: String
    var profile: String?
    var authProvider: String
    var socialToken: String?
    var refreshToken: String?
    var socialTokenExpiredAt: String?
    var lastLoginAt: String?
    var createdAt: String?
    var updatedAt: String?
    var deletedAt: String?
}
