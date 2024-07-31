//
//  OnboardingViewModel.swift
//  Harmony
//
//  Created by 한수빈 on 7/31/24.
//

import Foundation
import Combine
import Alamofire

// MARK: - API Service

class HarmonyAPIService {
    private let baseURL = ""
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
        
        func joinGroup(userId: String, inviteCode: String, deviceToken: String, alias: String) async throws -> Group {
            let parameters: [String: Any] = [
                "userId": userId,
                "inviteCode": inviteCode,
                "deviceToken": deviceToken,
                "alias": alias
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

// MARK: - Data Models

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
}

struct OnboardingUpdateResponse: Codable {
    let message: String
    let userGroup: UserGroup
}

// MARK: - ViewModel

class OnboardingViewModel: ObservableObject {
    private let apiService: HarmonyAPIService
    
    @Published var groupName = "" {
        didSet { logStateChange("groupName", oldValue, groupName) }
    }
    @Published var alias = "" {
        didSet { logStateChange("alias", oldValue, alias) }
    }
    @Published var userName: String = "" {
        didSet { logStateChange("userName", oldValue, userName) }
    }
    @Published var inviteCode = "" {
        didSet { logStateChange("inviteCode", oldValue, inviteCode) }
    }
    @Published var isLoading = false {
        didSet { logStateChange("isLoading", oldValue, isLoading) }
    }
    @Published var errorMessage: String? {
        didSet { logStateChange("errorMessage", oldValue, errorMessage) }
    }
    @Published var currentGroup: Group? {
        didSet { logStateChange("currentGroup", oldValue, currentGroup) }
    }
    @Published var currentUserGroup: UserGroup? {
        didSet { logStateChange("currentUserGroup", oldValue, currentUserGroup) }
    }
    
    init(apiService: HarmonyAPIService = HarmonyAPIService()) {
        self.apiService = apiService
        print("OnboardingViewModel initialized")
    }
    
    private func logStateChange<T>(_ propertyName: String, _ oldValue: T, _ newValue: T) {
        print("[\(propertyName)] 변경: \(oldValue) -> \(newValue)")
    }
    
    func createGroup() {
        guard !groupName.isEmpty, !alias.isEmpty else {
            errorMessage = "그룹 이름과 별칭을 입력해주세요."
            print("Error: \(errorMessage ?? "")")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        print("Creating group with - userId: \(userId), deviceToken: \(deviceToken)")

        Task {
            do {
                let (group, inviteUrl, vipInviteUrl) = try await apiService.createGroup(name: groupName, alias: alias, userId: userId, deviceToken: deviceToken)
                

                DispatchQueue.main.async {
                    self.currentGroup = group
                    self.isLoading = false
                    print("Group created successfully - groupId: \(group.groupId), inviteUrl: \(inviteUrl), vipInviteUrl: \(vipInviteUrl)")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "그룹 생성 중 오류가 발생했습니다: \(error.localizedDescription)"
                    self.isLoading = false
                    print("Error creating group: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func joinGroup() {
        guard !inviteCode.isEmpty, !alias.isEmpty else {
            errorMessage = "초대 코드와 별칭을 입력해주세요."
            print("Error: \(errorMessage ?? "")")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        print("Joining group with - userId: \(userId), deviceToken: \(deviceToken), inviteCode: \(inviteCode)")
        
        Task {
            do {
                let group = try await apiService.joinGroup(userId: userId, inviteCode: inviteCode, deviceToken: deviceToken, alias: alias)
                
                DispatchQueue.main.async {
                    self.currentGroup = group
                    self.isLoading = false
                    print("Successfully joined group - groupId: \(group.groupId)")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "그룹 참여 중 오류가 발생했습니다: \(error.localizedDescription)"
                    self.isLoading = false
                    print("Error joining group: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateOnboardingInfo() {
        guard let groupId = currentGroup?.groupId else {
            errorMessage = "현재 그룹 정보가 없습니다."
            print("Error: \(errorMessage ?? "")")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? ""
        print("Updating onboarding info - userId: \(userId), groupId: \(groupId), alias: \(alias)")
        
        Task {
            do {
                let userGroup = try await apiService.updateOnboardingInfo(groupId: groupId, userId: userId, alias: alias, deviceToken: deviceToken)
                
                DispatchQueue.main.async {
                    self.currentUserGroup = userGroup
                    self.isLoading = false
                    print("Onboarding info updated successfully - userId: \(userGroup.userId), groupId: \(userGroup.groupId)")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "온보딩 정보 업데이트 중 오류가 발생했습니다: \(error.localizedDescription)"
                    self.isLoading = false
                    print("Error updating onboarding info: \(error.localizedDescription)")
                }
            }
        }
    }
}

class AuthInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        // UserDefaults에서 토큰을 가져옵니다.
        if let token = UserDefaults.standard.string(forKey: "serverToken") {
            urlRequest.headers.add(.authorization(bearerToken: token))
        }
        
        completion(.success(urlRequest))
    }
}
