//
//  AppDelegate+Extentions.swift
//  Harmony
//
//  Created by 한수빈 on 7/26/24.
//

import UIKit
import KakaoSDKCommon

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
        print(nativeAppKey)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        print("APNS token: \(token)")
        UserDefaultsManager.shared.setToken(token)
        print("dㅏㄴ녕하셔" + UserDefaultsManager.shared.getToken())
        
    }
}


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
