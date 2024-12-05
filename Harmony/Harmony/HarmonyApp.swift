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
        if let nativeAppKey = Bundle.main.nativeAppKey  {
            KakaoSDK.initSDK(appKey: nativeAppKey)
        } else {
            print("카카오 네이티브 앱 키를 로드하지 못했음")
            // TODO: - 네이티브 앱 키를 로드하지 못했을 때 처리해줘야하는 로직
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(memoryCardViewModel)
                .onOpenURL(perform: { url in
                    if(AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}
