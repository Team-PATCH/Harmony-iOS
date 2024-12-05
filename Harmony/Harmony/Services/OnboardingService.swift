//
//  OnboardingService.swift
//  Harmony
//
//  Created by 한수빈 on 8/1/24.
//

import UIKit
import Combine
import Alamofire
// TODO: - 요청, 응답에 필요한 모델 또한 리팩토링 필요
final class OnboardingService {
    private let session: Session
    
    init() {
        let interceptor = AuthInterceptor()
        self.session = Session(interceptor: interceptor)
    }
    
    private let baseURL: String = {
        guard let baseURL = Bundle.main.infoDictionary?["BASE_URL"] as? String else {
            fatalError("BASE_URL is not set in Info.plist")
        }
        return baseURL
    }()
    
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
    
    func updateOnboardingInfo(groupId: Int, userId: String, alias: String, userName: String, profile: UIImage, deviceToken: String) async throws -> OnboardingUpdateResponse {
        
        guard let token = UserDefaults.standard.string(forKey: "serverToken") else {
            throw UploadError.invalidResponse
        }

        return try await withCheckedThrowingContinuation { continuation in
            guard let imageData = profile.jpegData(compressionQuality: 0.7) else {
                continuation.resume(throwing: UploadError.imageCompressionFailed)
                return
            }
            
            AF.upload(multipartFormData: { multipartFormData in
                // 이미지 데이터 추가
                multipartFormData.append(imageData,
                                         withName: "profile",
                                         fileName: "profile.jpg",
                                         mimeType: "image/jpeg")
                
                // 다른 파라미터들 추가
                multipartFormData.append(Data(userId.utf8), withName: "userId")
                multipartFormData.append(Data(userName.utf8), withName: "userName")
                multipartFormData.append(Data(alias.utf8), withName: "alias")
                multipartFormData.append(Data(deviceToken.utf8), withName: "deviceToken")
                
            }, to: "\(baseURL)/group/\(groupId)/onboarding",
                      method: .post,
                      headers: ["Content-Type": "multipart/form-data", "Authorization": "Bearer \(token)"])
            .validate()
            .responseDecodable(of: OnboardingUpdateResponse.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

enum UploadError: Error {
    case imageCompressionFailed
    case invalidResponse
    case networkError(Error)
    case requestCancelled
}
