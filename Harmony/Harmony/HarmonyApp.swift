//
//  HarmonyApp.swift
//  Harmony
//
//  Created by 한범석 on 7/15/24.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

@main
struct HarmonyApp: App {
    
    @StateObject private var memoryCardViewModel = MemoryCardViewModel()
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    init() {
        // Kakao SDK 초기화
        guard let nativeAppKey = Bundle.main.nativeAppKey else {
            print("카카오 네이티브 앱 키를 로드하지 못했음")
            return
        }
        KakaoSDK.initSDK(appKey: nativeAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(memoryCardViewModel)
                .onOpenURL(perform: { url in
                    if(AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                       // print(a)
                    }
                })
        }
    }
}
