//
//  HomeView.swift
//  Harmony
//
//  Created by 조다은 on 7/23/24.
//

import SwiftUI

struct HomeView: View {
    @State private var isShowingMemoryCardCreate = false
    
    var body: some View {
        ZStack {
            // 기존 HomeView 내용
            
            Button("추억 카드 만들기") {
                isShowingMemoryCardCreate = true
            }
            
            if isShowingMemoryCardCreate {
                MemoryCardCreateView(isPresented: $isShowingMemoryCardCreate)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(.default, value: isShowingMemoryCardCreate)
    }
}

#Preview {
    HomeView()
}
