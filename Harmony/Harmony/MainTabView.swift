//
//  MainTabView.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Binding var isAuth: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case 0:
                    HomeView(isAuth: $isAuth)
                case 1:
                    MemoryCardsView()
                case 2:
                    QuestionMainView()
                case 3:
                    RoutineView()
                default:
                    HomeView(isAuth: $isAuth)
                }
            }
            
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}



//#Preview {
//    MainTabView()
//}
