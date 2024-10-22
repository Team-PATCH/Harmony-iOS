//
//  AppleSignInButton.swift
//  Harmony
//
//  Created by 한수빈 on 8/12/24.
//

import SwiftUI
import Alamofire
import AuthenticationServices


struct AppleSignInButton: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        SignInWithAppleButton(
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(let authResults):
                    print("Apple Login Successful")
                    
                    switch authResults.credential {
                    case let appleIDCredential as ASAuthorizationAppleIDCredential:
                        // 계정 정보 가져오기
                        let userId = appleIDCredential.user
                        let fullName = appleIDCredential.fullName
                        let nick = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
                        let email = appleIDCredential.email ?? ""
                        DispatchQueue.main.async {
                            // UserDefaults에 계정 정보 저장
                            UserDefaults.standard.set(userId, forKey: "userId")
                            UserDefaults.standard.set(nick, forKey: "nick")
                            UserDefaults.standard.set(email, forKey: "email")
                        }
                        // 백엔드에 로그인 요청
                        login(userId, email, nick)
                        
                    default:
                        break
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    print("error")
                }
            }
        )
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 50)
        .cornerRadius(5)
    }
    
    
    
    func login(_ userId: String, _ email: String, _ nick: String) {
        let endpoint = "https://harmony-api.azurewebsites.net/user/signup"
        let params: Parameters = [
            "userId": userId,
            "nick": nick,
            "authProvider": "apple",
            "socialToken": email,
            "refreshToken": "",
            "socialTokenExpiredAt": ""
        ]
        print(params)

        AF.request(endpoint, method: .post, parameters: params)
            .validate()
            .responseDecodable(of: AuthResponse.self) { res in
                switch res.result {
                case .success(let result):
                    print("User received: \(result.user)")
                    DispatchQueue.main.async {
                        UserDefaults.standard.setValue(result.token, forKey: "serverToken")
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        isLoggedIn = true
                    }
                case .failure(let error):
                    print("Login failed: \(error.localizedDescription)")
                }
            }
    }
    
}

struct LoginInfo: Codable {
    let userId: String
    let nick: String
    let profile: String?
    let authProvider: String
    let socialToken: String
    let refreshToken: String?
    let socialTokenExpiredAt: String?
}


