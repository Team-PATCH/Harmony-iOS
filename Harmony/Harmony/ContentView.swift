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
        NavigationStack(path: $onboardingViewModel.navigationPath) {
            Group {
                if onboardingViewModel.isOnboardingEnd && authViewModel.isLoggedIn {
                    MainTabView()
                        .environmentObject(authViewModel)
                } else if authViewModel.isLoggedIn && !onboardingViewModel.isOnboardingEnd {
                    AllowNotificationView(viewModel: onboardingViewModel)
                        .navigationDestination(for: NavigationDestination.self) { destination in
                            switch destination {
                                case .createGroup:
                                    CreateGroupSpaceView(viewModel: onboardingViewModel)
                                    
                                case .inputVIPInfo:
                                    InputVIPInfoView(viewModel: onboardingViewModel)
                                    
                                case .inputUserInfo:
                                    InputUserInfoView(viewModel: onboardingViewModel)
                                    
                                case .inviteVIP:
                                    InviteVIPView(viewModel: onboardingViewModel)
                                    
                                case .registerProfile:
                                    RegisterProfileView(viewModel: onboardingViewModel)
                                    
                                case .joinGroup:
                                    JoinGroupSpaceView(viewModel: onboardingViewModel)
                                    
                                case .enterGroup:
                                    EnterGroupSpaceView(viewModel: onboardingViewModel)
                                    
                            }
                        }
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
        }
        .environmentObject(onboardingViewModel)
    }
}

#Preview {
    ContentView()
}
