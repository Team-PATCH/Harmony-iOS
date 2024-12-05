//
//  SimpleOnboardingView.swift
//  Harmony
//
//  Created by 한범석 on 7/15/24.
//

import SwiftUI

struct SimpleOnboardingView: View {
    @Binding var isAuth: Bool
    @State var isOnboarding = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            Color.subGreen.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                Image("harmony-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 75)
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                
                VStack(spacing: 3) {
                    HStack {
                        Spacer()
                        Text("앱 시연")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.mainGreen)
                        + Text("을 위한")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.bl)
                        Spacer()
                    }
                    
                    Text("Simple Onboarding ")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.gray5)
                    + Text("뷰입니다! 😄")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.bl)
                }
                .multilineTextAlignment(.center)
                
                VStack(spacing: 15) {
                    
                    Button {
//                        handleVIPSelection()
                    } label: {
                        Text("VIP")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mainGreen)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button {
//                        handleMemberSelection()
                    } label: {
                        Text("Member")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray2)
                            .foregroundColor(.bl)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        self.isOnboarding = true
                    } label: {
                        Text("Onboarding")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.wh)
                            .foregroundColor(.mainGreen)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.mainGreen, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                
                Spacer()
            }
            
            VStack {
                Spacer()
                Image("moni-wholebody")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: UIScreen.main.bounds.height * 0.4)
                    .offset(y: UIScreen.main.bounds.height * 0.17)
            }
        }
        .fullScreenCover(isPresented: $isOnboarding) {
            LoginView()
                .environmentObject(authViewModel)
        }
    }
}

/*
extension SimpleOnboardingView {
    private func handleVIPSelection() {
        saveUserData(permission: "v")
        onboardingViewModel.isOnboardingEnd = true
        authViewModel.isLoggedIn = true
        isAuth = true
    }
    
    private func handleMemberSelection() {
        saveUserData(permission: "m")
        onboardingViewModel.isOnboardingEnd = true
        authViewModel.isLoggedIn = true
        isAuth = true 
    }
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
*/
