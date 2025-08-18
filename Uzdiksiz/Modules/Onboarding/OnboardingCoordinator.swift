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
    private var onFinish: (() -> Void)?
    
    init(
        navigationController: UINavigationController,
        appState: AppState,
        onFinish: (() -> Void)? = nil
    ) {
        self.navigationController = navigationController
        self.appState = appState
        self.onFinish = onFinish
    }
    
    func start() {
        let onboardingView = OnboardingPage(onFinish: { [weak self] in
            self?.appState.markOnboardingCompleted()
            self?.stop()
        })
        
        let vc = UIHostingController(rootView: onboardingView)
        navigationController.setViewControllers([vc], animated: false)
    }
    
    func stop() {
        navigationController.setViewControllers([], animated: false)
        onFinish?()
    }
}
