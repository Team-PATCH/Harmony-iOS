//
//  CustomTabBar.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(height: 0.8)
                .foregroundStyle(Color.gray3)
                .padding(.bottom, 5)
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    CustomTabBarItem(selectedTab: $selectedTab, tabIndex: 0, image: "tab-home-icon", text: "홈")
                        .frame(width: geometry.size.width / 4)
                    CustomTabBarItem(selectedTab: $selectedTab, tabIndex: 1, image: "tab-memory-icon", text: "추억 보관소")
                        .frame(width: geometry.size.width / 4)
                    CustomTabBarItem(selectedTab: $selectedTab, tabIndex: 2, image: "tab-question-icon", text: "질문")
                        .frame(width: geometry.size.width / 4)
                    CustomTabBarItem(selectedTab: $selectedTab, tabIndex: 3, image: "tab-routine-icon", text: "일과")
                        .frame(width: geometry.size.width / 4)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 63)
        .background(Color.white)
    }
}

struct CustomTabBarItem: View {
    @Binding var selectedTab: Int
    let tabIndex: Int
    let image: String
    let text: String
    
    var body: some View {
        Button(action: {
            selectedTab = tabIndex
        }) {
            VStack {
                Image(image)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(selectedTab == tabIndex ? Color.mainGreen : Color.gray3)
                Text(text)
                    .font(.pretendardMedium(size: 15))
                    .foregroundColor(selectedTab == tabIndex ? Color.mainGreen : Color.gray3)
            }
        }
    }
}
