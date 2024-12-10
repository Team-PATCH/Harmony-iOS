//
//  LoginView+Debug.swift
//  Harmony
//
//  Created by 한범석 on 11/26/24.
//

import SwiftUI

#if DEBUG

extension LoginView {
    func handleVIPEntry() {
        saveUserData(permission: "v")
        authViewModel.groupId = 1
        authViewModel.isLoggedIn = true
    }
    
    func handleMemberEntry() {
        saveUserData(permission: "m")
        authViewModel.groupId = 1
        authViewModel.isLoggedIn = true
    }
    
    func saveUserData(permission: String) {
        let userData: UserData
        if permission == "v" {
            userData = UserData(
                userId: "yeojeong@naver.com",
                nick: "윤여정",
                permissionId: "v",
                groupId: 1,
                alias: "할머니 윤여정",
                deviceToken: "token123"
            )
        } else {
            userData = UserData(
                userId: "user2@example.com",
                nick: "최우식",
                permissionId: "m",
                groupId: 1,
                alias: "손자 최우식",
                deviceToken: "token456"
            )
        }
        UserDefaultsManager.shared.saveUserData(userData)
    }
}

struct DebugLoginButtons: View {
    let handleVIPEntry: () -> Void
    let handleMemberEntry: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Button("VIP로 진입") {
                handleVIPEntry()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.mainGreen)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Member로 진입") {
                handleMemberEntry()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray2)
            .foregroundColor(.bl)
            .cornerRadius(10)
        }
    }
}

#endif

