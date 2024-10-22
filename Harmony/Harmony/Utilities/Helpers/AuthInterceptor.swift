//
//  AuthInterceptor.swift
//  Harmony
//
//  Created by 한수빈 on 8/1/24.
//

import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        // UserDefaults에서 토큰을 가져옵니다.
        if let token = UserDefaults.standard.string(forKey: "serverToken") {
            urlRequest.headers.add(.authorization(bearerToken: token))
        }
        
        completion(.success(urlRequest))
    }
}
