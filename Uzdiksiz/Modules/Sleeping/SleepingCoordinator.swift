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
    let sleptDate: Date?
    init(navigationController: UINavigationController, sleepLogViewModel: SleepLogViewModel, sleepReportViewModel: SleepReportViewModel, sleepTimeViewModel: SleepTimeViewModel, sleptDate: Date?) {
        self.navigationController = navigationController
        self.sleepLogViewModel = sleepLogViewModel
        self.sleepReportViewModel = sleepReportViewModel
        self.sleepTimeViewModel = sleepTimeViewModel
        self.sleptDate = sleptDate
    }

    func start() {
        let sleepingView = SleepingPage(timeViewModel: sleepTimeViewModel, reportsViewModel: sleepReportViewModel, sleptDate: sleptDate).injectAppState()
        let viewController = UIHostingController(rootView: sleepingView)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController, animated: false, completion: nil)
    }

    func stop() {
        navigationController.dismiss(animated: false)
        // Cleanup if needed
    }
}
