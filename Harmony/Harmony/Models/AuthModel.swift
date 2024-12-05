//
//  AuthModel.swift
//  Harmony
//
//  Created by 한수빈 on 7/29/24.
//


struct AuthResponse: Codable {
    let message: String
    let user: AuthModel
    let token: String
}

struct AuthModel: Codable {
    let nick: String
    let authProvider: String
    let groupId: Int
    let permissionId: String?
}
