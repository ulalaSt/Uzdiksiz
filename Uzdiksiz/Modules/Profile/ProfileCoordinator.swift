//
//  ProfileCoordinator.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 07.08.2025.
//

import UIKit
import SwiftUI

final class ProfileCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let sleepReportViewModel: SleepReportViewModel
    private let sleepTimeViewModel: SleepTimeViewModel

    init(navigationController: UINavigationController, sleepReportViewModel: SleepReportViewModel, sleepTimeViewModel: SleepTimeViewModel) {
        self.navigationController = navigationController
        self.sleepReportViewModel = sleepReportViewModel
        self.sleepTimeViewModel = sleepTimeViewModel
    }

    func start() {
        let viewController = UIHostingController(rootView: ProfileView(sleepReportViewModel: sleepReportViewModel, sleepTimeViewModel: sleepTimeViewModel).injectAppState())
        viewController.view.backgroundColor = .clear
        navigationController.setViewControllers([viewController], animated: false)
    }

    func stop() {
        // Optional cleanup
    }
}
