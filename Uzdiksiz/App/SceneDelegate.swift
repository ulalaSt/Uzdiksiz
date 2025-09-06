//
//  SceneDelegate.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 04.08.2025.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    let environment = AppEnvironment(authService: FirebaseAuthService())
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let navController = UINavigationController()
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()

        // Создание и запуск AuthCoordinator
        let coordinator = AppCoordinator(
            navigationController: navController,
            environment: environment
        )
        appCoordinator = coordinator
        coordinator.start()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        checkPermission()
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
