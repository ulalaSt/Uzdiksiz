//
//  HomeCoordinator.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 07.08.2025.
//

import UIKit
import SwiftUI

final class HomeCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let appState: AppState
    private let environment: AppEnvironment
    private let sleepLogViewModel: SleepLogViewModel
    
    init(navigationController: UINavigationController, appState: AppState, environment: AppEnvironment, sleepLogViewModel: SleepLogViewModel) {
        self.navigationController = navigationController
        self.appState = appState
        self.environment = environment
        self.sleepLogViewModel = sleepLogViewModel
    }

    func start() {
        let viewModel = HomeViewModel(appState: appState, environment: environment)
        let viewController = UIHostingController(rootView: TodayView(viewModel: sleepLogViewModel))
        viewController.view.backgroundColor = .clear
        viewModel.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }

    func stop() {
        // Handle clean up if needed
    }
}
