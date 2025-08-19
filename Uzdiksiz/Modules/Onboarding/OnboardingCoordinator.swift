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
    private let appState: AppState
    private let hasCompletedInfoSections: Bool
    
    init(
        navigationController: UINavigationController,
        appState: AppState,
        hasCompletedInfoSections: Bool
    ) {
        self.navigationController = navigationController
        self.appState = appState
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
            self?.appState.markInfoSectionsCompleted()
            self?.showTimeSelectorPage()
        })
        
        let vc = UIHostingController(rootView: onboardingView)
        navigationController.setViewControllers([vc], animated: false)
    }
    
    func showTimeSelectorPage() {
        let targetTimeSelectorView = TargetTimeSelectionPage { [weak self] in
            self?.appState.markOnboardingCompleted()
        }
        
        let vc = UIHostingController(rootView: targetTimeSelectorView)
        navigationController.setViewControllers([vc], animated: false)
    }

    func stop() {
        navigationController.setViewControllers([], animated: false)
    }
}
