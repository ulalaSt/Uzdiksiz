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
    private var appState: AppState = .shared
    private let authViewModel: AuthViewModel
    private let sleepLogViewModel: SleepLogViewModel = .init()
    private let sleepReportViewModel = SleepReportViewModel()

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
        self.authViewModel = AuthViewModel(service: environment.authService)
    }

    func start() {
        switchFlow(hasCompletedOnboarding: appState.hasCompletedOnboarding, hasCompletedInfoSections: appState.hasCompletedInfoSections, sleptDate: appState.todaySleptDate)
        Publishers.CombineLatest3(appState.$hasCompletedOnboarding, appState.$hasCompletedInfoSections, appState.$todaySleptDate)
            .removeDuplicates { lhs, rhs in
                lhs.0 == rhs.0 && lhs.1 == rhs.1 && lhs.2 == rhs.2
            }
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] hasCompletedOnboarding, hasCompletedInfoSections, sleptDate in
                self?.switchFlow(
                    hasCompletedOnboarding: hasCompletedOnboarding,
                    hasCompletedInfoSections: hasCompletedInfoSections,
                    sleptDate: sleptDate
                )
            }
            .store(in: &cancellables)
    }

//    private func observeAuthorization() {
//        appState.$user
//            .removeDuplicates()
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] user in
//                self?.switchFlow(user: user)
//            }
//            .store(in: &cancellables)
//        environment.authService.userPublisher.sink { [weak self] user in
//            self?.appState.user = user
//        }
//        .store(in: &cancellables)
//    }
    
    private func switchFlow(hasCompletedOnboarding: Bool, hasCompletedInfoSections: Bool, sleptDate: Date?) {
        currentCoordinator?.stop()
        currentCoordinator = nil
        let coordinator: Coordinator
        if hasCompletedOnboarding {
            if let sleptDate {
                coordinator = SleepingCoordinator(navigationController: navigationController, sleepLogViewModel: sleepLogViewModel, sleepReportViewModel: sleepReportViewModel)
            } else {
                coordinator = MainTabBarCoordinator(navigationController: navigationController, appState: appState, environment: environment, authViewModel: authViewModel, sleepLogViewModel: sleepLogViewModel, sleepReportViewModel: sleepReportViewModel)
            }
        } else {
            coordinator = OnboardingCoordinator(navigationController: navigationController, appState: appState, hasCompletedInfoSections: hasCompletedInfoSections)
        }
        currentCoordinator = coordinator
        coordinator.start()
    }
}
