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
    
    func createGroup(name: String, userId: String, deviceToken: String) async throws -> (Int, String, String, String) {
        let parameters: [String: Any] = [
            "name": name,
            "userId": userId,
            "deviceToken": deviceToken
        ]
        
        let response: GroupCreationResponse = try await session.request("\(baseURL)/group", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .serializingDecodable(GroupCreationResponse.self)
            .value
        
        return (response.groupId, response.groupName, response.inviteUrl, response.vipInviteUrl)
    }
    
    func joinGroup(userId: String, inviteCode: String, deviceToken: String) async throws -> GroupJoinResponse {
        let parameters: [String: Any] = [
            "userId": userId,
            "inviteCode": inviteCode,
            "deviceToken": deviceToken,
        ]
        
        let response: GroupJoinResponse = try await session.request("\(baseURL)/group/join", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .serializingDecodable(GroupJoinResponse.self)
            .value
        
        return response
    }
    
    func updateOnboardingInfo(groupId: Int, userId: String, alias: String, userName: String, profile: String, deviceToken: String) async throws -> OnboardingUpdateResponse {
        let parameters: [String: Any] = [
            "userId": userId,
            "userName": userName,
            "profile": profile,
            "alias": alias,
            "deviceToken": deviceToken
        ]
        
        let response: OnboardingUpdateResponse = try await session.request("\(baseURL)/group/\(groupId)/onboarding", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .serializingDecodable(OnboardingUpdateResponse.self)
            .value
        
        return response
    }
    
}
