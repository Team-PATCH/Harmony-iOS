//
//  ContentView.swift
//  Harmony
//
//  Created by 한범석 on 7/15/24.
//

import SwiftUI

struct ContentView: View {
    @State var isAuth = false
    var body: some View {
        if isAuth {
            MemoryCardsView()
        } else {
            SimpleOnboardingView(isAuth: $isAuth)
        }
    }
}

#Preview {
    ContentView()
}
