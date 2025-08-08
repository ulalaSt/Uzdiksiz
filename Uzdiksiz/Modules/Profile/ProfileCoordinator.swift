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
    private let appState: AppState
    private let environment: AppEnvironment
    private let authViewModel: AuthViewModel
    private let locationManager: LocationManager

    init(navigationController: UINavigationController, appState: AppState, environment: AppEnvironment, authViewModel: AuthViewModel, locationManager: LocationManager) {
        self.navigationController = navigationController
        self.appState = appState
        self.environment = environment
        self.authViewModel = authViewModel
        self.locationManager = locationManager
    }

    func start() {
        let viewController = UIHostingController(rootView: ProfileView(authViewModel: authViewModel, locationManager: locationManager))
        viewController.view.backgroundColor = .clear
        navigationController.setViewControllers([viewController], animated: false)
    }

    func stop() {
        // Optional cleanup
    }
}
