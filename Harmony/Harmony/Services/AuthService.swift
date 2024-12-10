//
//  AuthService.swift
//  Harmony
//
//  Created by 한수빈 on 11/26/24.
//

import Alamofire
import AuthenticationServices

final class AuthService {
    
    static let shared = AuthService()
    private let session: Session
    
    private init() {
        let interceptor = AuthInterceptor()
        self.session = Session(interceptor: interceptor)
    }
    
    private let baseURL: String = {
        guard let baseURL = Bundle.main.infoDictionary?["BASE_URL"] as? String else {
            fatalError("BASE_URL is not set in Info.plist")
        }
        return baseURL
    }()
    
    func loginServiceKakao(userId: String, nick: String, socialToken: String, refreshToken: String, socialTokenExpiredAt: String) async throws -> AuthResponse {
        let endpoint = baseURL + "/user/signup"
        let parameters: Parameters = [ "userId": userId,
                                   "nick": nick,
                                   "authProvider": "kakao",
                                   "socialToken": socialToken,
                                   "refreshToken": refreshToken,
                                   "socialTokenExpiredAt": socialTokenExpiredAt ]
        
        let response: AuthResponse = try await session.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .serializingDecodable(AuthResponse.self)
            .value
        
        return response
    }
    
    func loginServiceApple(appleIDCredential: ASAuthorizationAppleIDCredential) async throws -> AuthResponse {
        let endpoint = baseURL + "/user/signup"
        let parameters: Parameters = [ "userId": appleIDCredential.user,
                                   "nick": (appleIDCredential.fullName?.familyName) ?? "" + (appleIDCredential.fullName?.givenName ?? ""),
                                   "authProvider": "apple",
                                   "socialToken": String(data: appleIDCredential.identityToken!, encoding: .utf8)!,
                                   "refreshToken": "",
                                   "socialTokenExpiredAt": ""]
        
        
        let response: AuthResponse = try await session.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .serializingDecodable(AuthResponse.self)
            .value
        
        return response
    }
}
