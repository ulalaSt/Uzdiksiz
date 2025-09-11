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
    private let tabBarController: MainTabBarController
    private(set) var childCoordinators: [Coordinator] = []
    private let sleepLogViewModel: SleepLogViewModel
    private let sleepReportViewModel: SleepReportViewModel
    private let locationManager: LocationManager
    private let authViewModel: AuthViewModel
    private let timeViewModel: SleepTimeViewModel
    init(navigationController: UINavigationController, authViewModel: AuthViewModel, sleepLogViewModel: SleepLogViewModel, sleepReportViewModel: SleepReportViewModel, timeViewModel: SleepTimeViewModel) {
        self.navigationController = navigationController
        self.tabBarController = MainTabBarController()
        self.sleepLogViewModel = sleepLogViewModel
        self.locationManager = LocationManager()
        self.authViewModel = authViewModel
        self.sleepReportViewModel = sleepReportViewModel
        self.timeViewModel = timeViewModel
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
                let homeCoordinator = HomeCoordinator(navigationController: nav, sleepLogViewModel: sleepLogViewModel, timeViewModel: timeViewModel)
                coordinator = homeCoordinator
            case .history:
                coordinator = HistoryCoordinator(navigationController: nav, sleepLogViewModel: sleepLogViewModel, sleepReportViewModel: sleepReportViewModel)
            case .goal:
                coordinator = GoalCoordinator(navigationController: nav)
            case .profile:
                coordinator = ProfileCoordinator(navigationController: nav, sleepReportViewModel: sleepReportViewModel, sleepTimeViewModel: timeViewModel)
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
        tabBarController.selectedIndex = 1
        navigationController.isNavigationBarHidden = true
        navigationController.setViewControllers([tabBarController], animated: false)
        navigationController.topViewController?.dismiss(animated: true, completion: nil)
    }
    
    func stop() {
    }
    
    deinit {
        print("DEINITED MainTabBarCoordinator")
    }
}
