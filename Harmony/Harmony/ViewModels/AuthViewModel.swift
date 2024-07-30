//
//  AuthViewModel.swift
//  Harmony
//
//  Created by 한수빈 on 7/28/24.
//

import Foundation
import KakaoSDKUser
import Alamofire

final class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var user: AuthModel
    
    
    init() {
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        user = AuthModel(userId: "", nick: "", authProvider: "")
    }
    
    func loginWithKakao() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error {
                    print(error)
                } else {
                    print("loginWithKakaoTalk() success.")
                    print("오어스토큰. \(oauthToken)")
                    guard let oauthToken else { return }
                    
                    UserDefaults.standard.setValue(oauthToken.accessToken, forKey: "socialToken")
                    UserDefaults.standard.setValue(oauthToken.expiredAt.toString(), forKey: "expiredAt")
                    UserDefaults.standard.setValue(oauthToken.refreshToken, forKey: "refreshToken")
                    
                    self.getUserInfo()
                }
            }
        }
    }
    
    private func getUserInfo() {
        UserApi.shared.me { (user, error) in
            if let error {
                print(error)
            } else {
                if let user {
                    guard let id = user.id,
                          let nick = user.kakaoAccount?.profile?.nickname,
                          let profile = user.kakaoAccount?.profile?.profileImageUrl else { return }
                    
                    UserDefaults.standard.setValue(id, forKey: "userId")
                    UserDefaults.standard.setValue(nick, forKey: "nick")
                    //UserDefaults.standard.setValue(profile, forKey: "profile")
                    self.user.userId = String(id)
                    self.user.nick = nick
                    self.user.authProvider = "kakao"
                    self.user.socialToken = UserDefaults.standard.string(forKey: "socialToken")
                    self.user.refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
                    self.user.socialTokenExpiredAt = UserDefaults.standard.string(forKey: "expiredAt")
                    
                    let endpoint = "https://harmony-api.azurewebsites.net/user/signup"
                    let params: Parameters = [ "userId": self.user.userId,
                                               "nick": self.user.nick,
                                               "profile": "",
                                               "authProvider": self.user.authProvider,
                                               "socialToken": self.user.socialToken ?? "",
                                               "refreshToken": self.user.refreshToken ?? "",
                                               "socialTokenExpiredAt": self.user.socialTokenExpiredAt ?? ""]
                    print(params)
                    AF.request(endpoint, method: .post, parameters: params)
                        .validate()
                        .responseDecodable(of: AuthRes.self) { res in
                            switch res.result {
                            case .success(let result):
                                UserDefaults.standard.setValue(result.token, forKey: "serverToken")
                                print("제발 \(result)")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                        

                    self.isLoggedIn = true
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    
                }
            }
        }
    }
}

