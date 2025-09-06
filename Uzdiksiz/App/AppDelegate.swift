//
//  AppDelegate.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 04.08.2025.
//
import UIKit
import Firebase
import GoogleSignIn
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        requestPermission()
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        checkPermission()
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async {
                    AppState.shared.notificationIsPermitted = granted
                }
            }
    }
    
    private func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                AppState.shared.notificationIsPermitted = (
                    settings.authorizationStatus == .authorized ||
                    settings.authorizationStatus == .provisional ||
                    settings.authorizationStatus == .ephemeral
                )
            }
        }
    }
}
