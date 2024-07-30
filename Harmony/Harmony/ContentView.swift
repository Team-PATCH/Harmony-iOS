//
//  ContentView.swift
//  Harmony
//
//  Created by 한범석 on 7/15/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()

    var body: some View {
        if authViewModel.isLoggedIn {
            AllowNotificationView()
        } else {
            LoginView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    ContentView()
}
