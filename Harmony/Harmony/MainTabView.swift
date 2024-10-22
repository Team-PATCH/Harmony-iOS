//
//  MainTabView.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var memoryCardViewModel: MemoryCardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case 0:
                    HomeView()
                            .environmentObject(memoryCardViewModel)
                case 1:
                    MemoryCardsView()
                            .environmentObject(memoryCardViewModel)
                case 2:
                    QuestionMainView()
                case 3:
                    RoutineView()
                default:
                    HomeView()
                            .environmentObject(memoryCardViewModel)
                }
            }
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}



//#Preview {
//    MainTabView()
//}
