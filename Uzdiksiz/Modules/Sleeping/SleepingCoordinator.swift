//
//  SleepingCoordinator.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 22.08.2025.
//

import UIKit
import SwiftUI

final class SleepingCoordinator: Coordinator {
    let navigationController: UINavigationController
    let sleepLogViewModel: SleepLogViewModel
    init(navigationController: UINavigationController, sleepLogViewModel: SleepLogViewModel) {
        self.navigationController = navigationController
        self.sleepLogViewModel = sleepLogViewModel
    }

    func start() {
        let viewmodel = SleepingViewModel(logService: sleepLogViewModel)
        // Create SwiftUI view with callback for wakeUp
        let sleepingView = SleepingPage(viewModel: viewmodel)
        let viewController = UIHostingController(rootView: sleepingView)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController, animated: true, completion: nil)
    }

    func stop() {
        // Cleanup if needed
    }
}
