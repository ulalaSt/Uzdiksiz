//
//  AlarmCoordinator.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 22.08.2025.
//

import UIKit
import SwiftUI

final class AlarmCoordinator: Coordinator {
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
        let alarmPage = AlarmPage(timeViewModel: sleepTimeViewModel, reportsViewModel: sleepReportViewModel)
        let viewController = UIHostingController(rootView: alarmPage)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController, animated: false, completion: nil)
    }

    func stop() {
        navigationController.dismiss(animated: false, completion: nil)
    }
}
