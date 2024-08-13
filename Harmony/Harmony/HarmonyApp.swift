//
//  HarmonyApp.swift
//  Harmony
//
//  Created by 한범석 on 7/15/24.
//

import SwiftUI

@main
struct HarmonyApp: App {
    
    @StateObject private var memoryCardViewModel = MemoryCardViewModel()
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(memoryCardViewModel)
        }
    }
}
