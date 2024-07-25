//
//  UserDefaultsManager.swift
//  Harmony
//
//  Created by 한수빈 on 7/22/24.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init() {}
    
    private let userDataKey = "userData"
    
    func saveUserData(_ userData: UserData) {
        if let encoded = try? JSONEncoder().encode(userData) {
            UserDefaults.standard.set(encoded, forKey: userDataKey)
        }
    }
    
    func getUserData() -> UserData? {
        guard let savedUserData = UserDefaults.standard.data(forKey: userDataKey),
              let loadedUserData = try? JSONDecoder().decode(UserData.self, from: savedUserData) else {
            return nil
        }
        return loadedUserData
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: userDataKey)
    }
    
    // 개별 속성에 대한 getter 메서드들
    func getUserId() -> String? {
        return getUserData()?.userId
    }
    
    func getNick() -> String? {
        return getUserData()?.nick
    }
    
    func getPermissionId() -> String? {
        return getUserData()?.permissionId
    }
    
    func getGroupId() -> Int? {
        return getUserData()?.groupId
    }
    
    func getAlias() -> String? {
        return getUserData()?.alias
    }
    
    func getDeviceToken() -> String? {
        return getUserData()?.deviceToken
    }
    
    // 사용자가 인증되었는지 확인하는 메서드
    func isUserAuthenticated() -> Bool {
        return getUserData() != nil
    }
}

struct UserData: Codable {
    let userId: String
    let nick: String
    let permissionId: String
    let groupId: Int
    let alias: String
    let deviceToken: String
}
