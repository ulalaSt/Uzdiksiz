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

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        // Create SwiftUI view with callback for wakeUp
        let sleepingView = SleepingPage()
        let viewController = UIHostingController(rootView: sleepingView)
        navigationController.setViewControllers([viewController], animated: true)
    }

    func stop() {
        // Cleanup if needed
    }
}
