//
//  AppCoordinator.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 04.08.2025.
//
import UIKit
import Combine
import SwiftUI
import FirebaseAuth

final class AppCoordinator {
    private let environment: AppEnvironment
    private let navigationController: UINavigationController

    private var currentCoordinator: Coordinator?
    private var cancellables = Set<AnyCancellable>()
    private var appState: AppState
    private let authViewModel: AuthViewModel

    init(navigationController: UINavigationController,
         environment: AppEnvironment) {
        self.navigationController = navigationController
        self.environment = environment
        let user: Loadable<AppUser>
        if let currentUser = environment.authService.user.value {
            user = .loaded(currentUser)
        } else {
            user = .failed(.notRegistered)
        }
        let appState = AppState(user: user)
        self.appState = appState
        self.authViewModel = AuthViewModel(appState: appState, service: environment.authService)
    }

    func start() {
        observeAuthorization()
    }

    private func observeAuthorization() {
        appState.$user
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.switchFlow(user: user)
            }
            .store(in: &cancellables)
        environment.authService.userPublisher.sink { [weak self] user in
            self?.appState.user = user
        }
        .store(in: &cancellables)
    }
    
    private func switchFlow(user: Loadable<AppUser>) {
        currentCoordinator?.stop()
        currentCoordinator = nil
        if let user = user.value {
            let mainCoordinator = MainTabBarCoordinator(navigationController: navigationController, appState: appState, environment: environment, authViewModel: authViewModel)
            currentCoordinator = mainCoordinator
            mainCoordinator.start()
        } else {
            let authCoordinator = AuthCoordinator(navigationController: navigationController, appState: appState, environment: environment, authViewModel: authViewModel)
            currentCoordinator = authCoordinator
            authCoordinator.start()
        }
    }
}
