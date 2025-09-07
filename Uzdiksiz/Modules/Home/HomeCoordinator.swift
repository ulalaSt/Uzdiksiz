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
    let timeViewModel: SleepTimeViewModel

    init(navigationController: UINavigationController, sleepLogViewModel: SleepLogViewModel, timeViewModel: SleepTimeViewModel) {
        self.navigationController = navigationController
        self.timeViewModel = timeViewModel
    }

    func start() {
        let viewController = UIHostingController(rootView: HomePage(viewModel: timeViewModel))
        viewController.view.backgroundColor = .clear
        navigationController.setViewControllers([viewController], animated: false)
    }

    func stop() {
        // Handle clean up if needed
    }
    
    func openSettings(state: SleepSettingsState) {
        let viewController = UIHostingController(rootView: SleepSettingsPage(state: state, viewModel: timeViewModel))
        navigationController.pushViewController(viewController, animated: true)
    }
}
