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
    let viewModel: SleepTimeViewModel

    init(navigationController: UINavigationController, appState: AppState, environment: AppEnvironment, sleepLogViewModel: SleepLogViewModel) {
        self.navigationController = navigationController
        self.appState = appState
        self.environment = environment
        self.sleepLogViewModel = sleepLogViewModel
        self.viewModel = SleepTimeViewModel(environment: environment)
        viewModel.coordinator = self
    }

    func start() {
        let viewController = UIHostingController(rootView: HomePage(viewModel: viewModel))
        viewController.view.backgroundColor = .clear
        navigationController.setViewControllers([viewController], animated: false)
    }

    func stop() {
        // Handle clean up if needed
    }
    
    func openSettings(state: SleepSettingsState) {
        let viewController = UIHostingController(rootView: SleepSettingsPage(state: state, viewModel: viewModel))
        navigationController.pushViewController(viewController, animated: true)
    }
}
