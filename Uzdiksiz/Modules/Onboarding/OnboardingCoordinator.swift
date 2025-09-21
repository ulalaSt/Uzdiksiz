//
//  OnboardingCoordinator.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 17.08.2025.
//

import UIKit
import SwiftUI
import SwiftUI
import UIKit

final class OnboardingCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let hasCompletedInfoSections: Bool
    
    init(
        navigationController: UINavigationController,
        hasCompletedInfoSections: Bool
    ) {
        self.navigationController = navigationController
        self.hasCompletedInfoSections = hasCompletedInfoSections
    }
    
    func start() {
        if hasCompletedInfoSections {
            showTimeSelectorPage()
        } else {
            showOnboardingPage()
        }
    }
    
    func showOnboardingPage() {
        let onboardingView = OnboardingPage(onFinish: { [weak self] in
            AppState.shared.hasCompletedInfoSections = true
            self?.showTimeSelectorPage()
        })
        
        let vc = UIHostingController(rootView: onboardingView.injectAppState())
        navigationController.setViewControllers([vc], animated: false)
    }
    
    func showTimeSelectorPage() {
        let targetTimeSelectorView = TargetTimeSelectionPage { sleepTime, wakeTime in
            AppState.shared.sleepTime = sleepTime
            AppState.shared.wakeTime = wakeTime
            AppState.shared.hasCompletedOnboarding = true
        }
        
        let vc = UIHostingController(rootView: targetTimeSelectorView.injectAppState())
        navigationController.setViewControllers([vc], animated: true)
    }

    func stop() {
    }
}
