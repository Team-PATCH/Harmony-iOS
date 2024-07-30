//
//  AppDelegate+Extentions.swift
//  Harmony
//
//  Created by 한수빈 on 7/26/24.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
        center.delegate = self
        guard let nativeAppKey = Bundle.main.nativeAppKey else {
            print("카카오 네이티브 앱 키를 로드하지 못했음")
            return false
        }
        KakaoSDK.initSDK(appKey: nativeAppKey)
        print("Kakao 네이티브 앱 키: \(nativeAppKey)")
        if (AuthApi.hasToken()) {
            UserApi.shared.accessTokenInfo { (token, error) in
                if let error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    }
                    else {
                        //기타 에러
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    }
                }
                else {
                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    print("토큰!!: \(token)")
                }
            }
        }
        else {
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            
            return AuthController.handleOpenUrl(url: url)
        }
        
        
        return false
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        
        UserDefaultsManager.shared.setToken(token)
        print("저장된 디바이스 토큰: " + UserDefaultsManager.shared.getToken())
        
    }
    
    
}

/// 푸쉬 알림 관련 설정
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let info = response.notification.request.content.userInfo
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let info = notification.request.content.userInfo
        print(info)
        completionHandler([.banner,.sound])
    }
}


