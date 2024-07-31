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
    
    func setToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "deviceToken")
    }
    
    func getToken() -> String {
        guard let token = UserDefaults.standard.string(forKey: "deviceToken") else { return "빈 토큰" }
        return token
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
    
    // 사용자가 인증되었는지 확인하는 메서드
    func isUserAuthenticated() -> Bool {
        return getUserData() != nil
    }
    
    func isVIP() -> Bool {
        return getPermissionId() == "v"
    }

    func isMember() -> Bool {
        return getPermissionId() == "m"
    }

    func isAdmin() -> Bool {
        return getPermissionId() == "a"
    }
}

struct UserData: Codable {
    let userId: String
    var nick: String //let -> var
    let permissionId: String
    let groupId: Int
    var alias: String //let -> var
    let deviceToken: String
}
