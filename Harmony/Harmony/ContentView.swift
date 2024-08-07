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
        if onboardingViewModel.isOnboardingEnd && authViewModel.isLoggedIn  {
            MainTabView()
        } else if authViewModel.isLoggedIn && !onboardingViewModel.isOnboardingEnd {
            NavigationStack(path: $onboardingViewModel.navigationPath) {
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
            }
            
        }
        else {
            LoginView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    ContentView()
}
