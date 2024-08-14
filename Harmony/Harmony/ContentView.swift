//
//  ContentView.swift
//  Harmony
//
//  Created by 한범석 on 7/15/24.
//

import SwiftUI

struct ContentView: View {
    @State var isAuth = false
    @EnvironmentObject var memoryCardViewModel: MemoryCardViewModel

    
    var body: some View {
        if isAuth {
            MainTabView(isAuth: $isAuth)
                .environmentObject(memoryCardViewModel)
        } else {
            SimpleOnboardingView(isAuth: $isAuth)
                .environmentObject(memoryCardViewModel)
        }
    }
}

#Preview {
    ContentView()
}
