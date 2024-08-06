//
//  OnboardingService.swift
//  Harmony
//
//  Created by 한수빈 on 8/1/24.
//

import Foundation
import Combine
import Alamofire

final class OnboardingService {
    private let baseURL = "https://harmony-api.azurewebsites.net"
    private let session: Session
    
    init() {
        let interceptor = AuthInterceptor()
        self.session = Session(interceptor: interceptor)
    }
    
    func createGroup(name: String, alias: String, userId: String, deviceToken: String) async throws -> (Group, String, String) {
        let parameters: [String: Any] = [
            "name": name,
            "alias": alias,
            "userId": userId,
            "deviceToken": deviceToken
        ]
        
        let response: GroupCreationResponse = try await session.request("\(baseURL)/group", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .serializingDecodable(GroupCreationResponse.self)
            .value
        
        return (response.group, response.inviteUrl, response.vipInviteUrl)
    }
    
    func joinGroup(userId: String, inviteCode: String, deviceToken: String) async throws -> Group {
        let parameters: [String: Any] = [
            "userId": userId,
            "inviteCode": inviteCode,
            "deviceToken": deviceToken,
        ]
        
        let response: GroupJoinResponse = try await session.request("\(baseURL)/group/join", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .serializingDecodable(GroupJoinResponse.self)
            .value
        
        return response.group
    }
    
    func updateOnboardingInfo(groupId: Int, userId: String, alias: String, deviceToken: String) async throws -> UserGroup {
        let parameters: [String: Any] = [
            "userId": userId,
            "alias": alias,
            "deviceToken": deviceToken
        ]
        
        let response: OnboardingUpdateResponse = try await session.request("\(baseURL)/group/\(groupId)/onboarding", method: .put, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .serializingDecodable(OnboardingUpdateResponse.self)
            .value
        
        return response.userGroup
    }
    
}
