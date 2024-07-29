//
//  AuthViewModel.swift
//  Harmony
//
//  Created by 한수빈 on 7/28/24.
//

import Foundation
import KakaoSDKUser

final class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userInfo: UserInfo?
    
    
    init() {
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    func loginWithKakao() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error {
                    print(error)
                } else {
                    print("loginWithKakaoTalk() success.")
                    self.getUserInfo()
                }
            }
        }
    }
    
    func getUserInfo() {
        UserApi.shared.me { (user, error) in
            if let error {
                print(error)
            } else {
                if let user {
                    self.userInfo = UserInfo(id: user.id,
                                             nickname: user.kakaoAccount?.profile?.nickname,
                                             profileImageUrl: user.kakaoAccount?.profile?.profileImageUrl)
                    self.isLoggedIn = true
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")

                }
            }
        }
    }
}

struct UserInfo {
    let id: Int64?
    let nickname: String?
    let profileImageUrl: URL?
}
