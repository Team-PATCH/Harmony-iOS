//
//  MainTabView.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    MemoryCardsView()
                case 2:
                    // Question View 추가
                    Text("Question View")
                case 3:
                    RoutineView()
                default:
                    HomeView()
                }
            }
            
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    MainTabView()
}
