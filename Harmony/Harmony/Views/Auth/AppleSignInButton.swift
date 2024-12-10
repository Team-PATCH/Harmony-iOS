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
    var completion: (ASAuthorizationAppleIDCredential) -> Void
    
    var body: some View {
        SignInWithAppleButton(
            .continue,
            
            onRequest: { request in
            request.requestedScopes = [.fullName, .email]
        },
            
            onCompletion: { result in
            switch result {
            case .success(let authResults):
                switch authResults.credential {
                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                    completion(appleIDCredential)
                default:
                    break
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
}
