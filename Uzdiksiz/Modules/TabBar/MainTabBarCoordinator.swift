//
//  MainTabBarCoordinator.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 07.08.2025.
//

import UIKit
import SwiftUICore

final class MainTabBarCoordinator: NSObject, Coordinator {
    let navigationController: UINavigationController
    private let appState: AppState
    private let environment: AppEnvironment
    private let tabBarController: MainTabBarController
    private(set) var childCoordinators: [Coordinator] = []
    private let sleepLogViewModel: SleepLogViewModel
    private let locationManager: LocationManager
    private let authViewModel: AuthViewModel
    
    init(navigationController: UINavigationController, appState: AppState, environment: AppEnvironment, authViewModel: AuthViewModel) {
        self.navigationController = navigationController
        self.appState = appState
        self.environment = environment
        self.tabBarController = MainTabBarController()
        self.sleepLogViewModel = SleepLogViewModel()
        self.locationManager = LocationManager()
        self.authViewModel = authViewModel
    }

    func start() {
        let tabs: [MainTab] = [.home, .history, .profile]
        var navControllers: [UINavigationController] = []
        childCoordinators = []
        
        tabs.forEach { tab in
            let nav = UINavigationController()
            let coordinator: Coordinator
            switch tab {
            case .home:
                coordinator = HomeCoordinator(navigationController: nav, appState: appState, environment: environment, sleepLogViewModel: sleepLogViewModel)
            case .history:
                coordinator = HistoryCoordinator(navigationController: nav, appState: appState, environment: environment, sleepLogViewModel: sleepLogViewModel)
            case .profile:
                coordinator = ProfileCoordinator(navigationController: nav, appState: appState, environment: environment, authViewModel: authViewModel, locationManager: locationManager)
            }
            
            let tabBarItem = UITabBarItem(
                title: tab.title,
                image: UIImage(systemName: tab.iconTitle),
                tag: tab.rawValue
            )
            nav.tabBarItem = tabBarItem
            navControllers.append(nav)
            coordinator.start()
            childCoordinators.append(coordinator)
        }
        tabBarController.viewControllers = navControllers
        navigationController.isNavigationBarHidden = true
        navigationController.setViewControllers([tabBarController], animated: false)
    }
    
    func stop() {
        navigationController.isNavigationBarHidden = false
        navigationController.setViewControllers([], animated: false)
    }
    
    deinit {
        print("DEINITED MainTabBarCoordinator")
    }
}
