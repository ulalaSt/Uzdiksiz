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
    let sleepReportViewModel: SleepReportViewModel
    let sleepTimeViewModel: SleepTimeViewModel
    init(navigationController: UINavigationController, sleepLogViewModel: SleepLogViewModel, sleepReportViewModel: SleepReportViewModel, sleepTimeViewModel: SleepTimeViewModel) {
        self.navigationController = navigationController
        self.sleepLogViewModel = sleepLogViewModel
        self.sleepReportViewModel = sleepReportViewModel
        self.sleepTimeViewModel = sleepTimeViewModel
    }

    func start() {
        let viewmodel = SleepingViewModel(logService: sleepLogViewModel)
        // Create SwiftUI view with callback for wakeUp
        let sleepingView = SleepingPage(timeViewModel: sleepTimeViewModel, reportsViewModel: sleepReportViewModel)
        let viewController = UIHostingController(rootView: sleepingView)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController, animated: true, completion: nil)
    }

    func stop() {
        // Cleanup if needed
    }
}
