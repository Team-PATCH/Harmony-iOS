//
//  ContentView.swift
//  Harmony
//
//  Created by 한범석 on 7/15/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var onboardingViewModel = OnboardingViewModel()
    
    var body: some View {
        if authViewModel.isLoggedIn  {
            if authViewModel.groupId > 0 || onboardingViewModel.isOnboardingEnd {
                MainTabView()
                    .environmentObject(authViewModel)
            } else if !onboardingViewModel.isOnboardingEnd {
                Group {
                    NavigationStack(path: $onboardingViewModel.navigationPath) {
                        AllowNotificationView()
                            .navigationDestination(for: NavigationDestination.self) { destination in
                                switch destination {
                                case .createGroup:
                                    CreateGroupSpaceView()
                                case .inputVIPInfo:
                                    InputVIPInfoView()
                                    
                                case .inputUserInfo:
                                    InputUserInfoView()
                                    
                                case .inviteVIP:
                                    InviteVIPView()
                                    
                                case .registerProfile:
                                    RegisterProfileView()
                                    
                                case .joinGroup:
                                    JoinGroupSpaceView()
                                    
                                case .enterGroup:
                                    EnterGroupSpaceView()
                                }
                            }
                    }
                }
                .environmentObject(onboardingViewModel)
            }
        } else {
            LoginView()
                .environmentObject(authViewModel)

        }
    }
}

#Preview {
    ContentView()
}
