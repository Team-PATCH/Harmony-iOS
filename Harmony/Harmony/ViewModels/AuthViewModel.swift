//
//  AuthViewModel.swift
//  Harmony
//
//  Created by 한수빈 on 7/28/24.
//

import Foundation
import KakaoSDKUser
import AuthenticationServices

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.setValue(isLoggedIn, forKey: "isLoggedIn")
        }
    }
    @Published var groupId: Int {
        didSet {
            UserDefaults.standard.setValue(groupId, forKey: "groupId")
        }
    }
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.groupId = UserDefaults.standard.integer(forKey: "groupId")
    }
    
    // MARK: - 카카오 로그인
    func loginWithKakao() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error {
                    print(error)
                } else {
                    guard let oauthToken else { return }
//                    String(data: oauthToken, encoding: .utf8)
                    self.getUserInfo(socialToken: oauthToken.accessToken, expiredAt: oauthToken.expiredAt.toString(), refreshToken: oauthToken.refreshToken)
                }
            }
        } else { // 카카오톡 미설치 시 앱스토어로 이동
            if let url = URL(string: "https://apps.apple.com/kr/app/kakaotalk/id362057947") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    // MARK: - 카카오 유저 정보조회
    private func getUserInfo(socialToken: String, expiredAt: String, refreshToken: String) {
        UserApi.shared.me { (user, error) in
            if let error {
                print(error)
            } else {
                if let user {
                    guard let userNumId = user.id,
                          let nick = user.kakaoAccount?.profile?.nickname
                    else {
                        print("error in\(#function)")
                        return
                    }
                    
                    let userId = "\(userNumId)"
                    Task {
                        do {
                            let response = try await AuthService.shared.loginServiceKakao(userId: userId, nick: nick, socialToken: socialToken, refreshToken: refreshToken, socialTokenExpiredAt: expiredAt)
                            UserDefaults.standard.set(response.token, forKey: "serverToken")
                            UserDefaults.standard.set(response.user.nick, forKey: "nick")
                            UserDefaults.standard.set(response.user.authProvider, forKey: "authProvider")
                            UserDefaults.standard.set(response.user.groupId, forKey: "groupId")
                            self.isLoggedIn = true
                        } catch {
                            print("error in \(#function)")
                            return
                        }
                    }
                }
            }
        }
    }
    
    
    func loginWithApple(appleIDCredential: ASAuthorizationAppleIDCredential) {
        Task {
            do {
                let response = try await AuthService.shared.loginServiceApple(appleIDCredential: appleIDCredential)
                UserDefaults.standard.set(response.token, forKey: "serverToken")
                UserDefaults.standard.set(response.user.nick, forKey: "nick")
                UserDefaults.standard.set(response.user.authProvider, forKey: "authProvider")
                self.isLoggedIn = true
                UserDefaults.standard.set(response.user.groupId, forKey: "groupId")
            } catch {
                print("error in \(#function)")
                return
            }
        }
    }
#if DEBUG
    func logout() {
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "nick")
    }
#endif
    
}

