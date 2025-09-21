//
//  GoalCoordinator.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 21.08.2025.
//

import UIKit
import SwiftUI

final class GoalCoordinator: Coordinator {
    let navigationController: UINavigationController
    let viewModel = GoalViewModel()
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        // Pass callbacks into the SwiftUI view
        let goalListView = GoalSettingPage(viewModel: viewModel,
            onGoalSelected: { [weak self] goal in
                self?.showGoalDetail(goal: goal)
            },
            onGoalAdded: { [weak self] goal in
                self?.handleGoalAdded(goal)
            }
        ).injectAppState()

        let viewController = UIHostingController(rootView: goalListView)
        navigationController.setViewControllers([viewController], animated: true)
    }

    func stop() {
        // Cleanup if needed
    }

    private func showGoalDetail(goal: Goal) {
        let detailView = GoalDetailPage(goal: goal, viewModel: viewModel, onSubGoalTap: { [weak self] goal in
            self?.showGoalDetail(goal: goal)
        })
        let vc = UIHostingController(rootView: detailView.injectAppState())
        navigationController.pushViewController(vc, animated: true)
    }

    private func handleGoalAdded(_ goal: Goal) {
        
    }
}
