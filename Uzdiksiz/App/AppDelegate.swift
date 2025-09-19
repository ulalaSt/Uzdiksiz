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
import AlarmKit

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
    
    private func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, _ in
                DispatchQueue.main.async {
                    AppState.shared.notificationIsPermitted = granted
                }
            }
        Task {
            do {
                try await checkAlarmPermission()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func checkAlarmPermission() async throws {
        if #available(iOS 26.0, *) {
            switch AlarmManager.shared.authorizationState {
            case .notDetermined:
                let status = try await AlarmManager.shared.requestAuthorization()
                AppState.shared.alarmIsPermitted = status == .authorized
            case .denied:
                AppState.shared.alarmIsPermitted = false
            case .authorized:
                AppState.shared.alarmIsPermitted = true
            @unknown default:
                AppState.shared.alarmIsPermitted = false
            }
        }
    }
}
