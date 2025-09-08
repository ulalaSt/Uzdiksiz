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
    private let sleepLogViewModel: SleepLogViewModel
    private let sleepReportViewModel: SleepReportViewModel

    init(navigationController: UINavigationController, sleepLogViewModel: SleepLogViewModel, sleepReportViewModel: SleepReportViewModel) {
        self.navigationController = navigationController
        self.sleepLogViewModel = sleepLogViewModel
        self.sleepReportViewModel = sleepReportViewModel
    }

    func start() {
        let viewController = UIHostingController(rootView: SleepStatsPage(viewModel: sleepReportViewModel, onShowGraph: { [weak self] in
        }, onAddSleep: {[weak self] date in
            self?.showAddSleep(date: date)
        }))
        viewController.view.backgroundColor = .clear
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showAddSleep(date: Date) {
        let viewController = UIHostingController(rootView: AddSleepLogPage(date: date, onSave: { [weak self] date, sleepTime, wakeTime in
            Task {
                await self?.sleepReportViewModel.createSleepSession(dateKey: date.dateKey, startTime: sleepTime, endTime: wakeTime, state: .constant(.notRequested))
            }
        }))
        viewController.view.backgroundColor = .clear
        navigationController.present(viewController, animated: true)
    }
        
    func navigateToGraph() {
        
    }
    
    func stop() {
        // Optional cleanup
    }
}
