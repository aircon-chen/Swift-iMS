//
//  AppDelegate.swift
//  iMS
//
//  Created by Chen Hsin Hsuan on 2015/5/21.
//  Copyright (c) 2015年 AirconTW. All rights reserved.
//

import UIKit
import StoreKit
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // 追蹤 App 使用次數以請求評價
    private let usageCountKey = "appUsageCount"
    private let reviewRequestedKey = "reviewRequested"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 初始化 Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // 設置測試設備（開發時使用）
        // 正式發布時請移除此設置
        let testDeviceIdentifiers = ["dde7df46d5116b14c2c0f8e4a7be1ae8"]
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = testDeviceIdentifiers
        print("📱 已設置測試設備 ID: \(testDeviceIdentifiers)")
        
        // 使用 StoreKit 請求評價（替代 iRate）
        incrementUsageCount()
        requestReviewIfNeeded()
        
        return true
    }
    
    // MARK: - App Review Helper Methods
    
    private func incrementUsageCount() {
        let currentCount = UserDefaults.standard.integer(forKey: usageCountKey)
        UserDefaults.standard.set(currentCount + 1, forKey: usageCountKey)
    }
    
    private func requestReviewIfNeeded() {
        let usageCount = UserDefaults.standard.integer(forKey: usageCountKey)
        let reviewRequested = UserDefaults.standard.bool(forKey: reviewRequestedKey)
        
        // 使用 3 次後請求評價（對應原本的 usesUntilPrompt = 3）
        if usageCount >= 3 && !reviewRequested {
            if #available(iOS 14.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                    UserDefaults.standard.set(true, forKey: reviewRequestedKey)
                }
            } else {
                // iOS 13 使用舊的 API
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(true, forKey: reviewRequestedKey)
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

