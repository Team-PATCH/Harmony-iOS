//
//  AuthViewModel.swift
//  Harmony
//
//  Created by 한수빈 on 7/28/24.
//

import Foundation
import KakaoSDKUser

import Foundation
import KakaoSDKUser

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userInfo: UserInfo?
    
    func loginWithKakao() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
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
            if let error = error {
                print(error)
            } else {
                if let user = user {
                    self.userInfo = UserInfo(id: user.id,
                                             nickname: user.kakaoAccount?.profile?.nickname,
                                             profileImageUrl: user.kakaoAccount?.profile?.profileImageUrl)
                    self.isLoggedIn = true
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
