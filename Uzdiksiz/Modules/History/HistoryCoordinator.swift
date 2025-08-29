//
//  HistoryCoordinator.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 07.08.2025.
//

import UIKit
import SwiftUI

final class HistoryCoordinator: Coordinator {
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
        let viewController = UIHostingController(rootView: SleepStatsPage(viewModel: sleepLogViewModel, onShowGraph: { [weak self] in
            self?.showOldSleepHistory()
        }))
        viewController.view.backgroundColor = .clear
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showOldSleepHistory() {
        let viewController = UIHostingController(rootView: SleepHistoryView(viewModel: sleepLogViewModel))
        viewController.view.backgroundColor = .clear
        navigationController.pushViewController(viewController, animated: true)
    }
    func navigateToGraph() {
        
    }
    
    func stop() {
        // Optional cleanup
    }
}
