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
import CoreData

final class AppCoordinator: NSObject, SettingsNavigator, SleepReportsNavigator {
    private let environment: AppEnvironment
    private let navigationController: UINavigationController

    private var currentCoordinator: Coordinator?
    private var cancellables = Set<AnyCancellable>()
    private let authViewModel: AuthViewModel
    private let sleepLogViewModel: SleepLogViewModel = .init()
    private let sleepReportViewModel = SleepReportViewModel()
    private let sleepTimeViewModel = SleepTimeViewModel()

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
        super.init()
        sleepTimeViewModel.coordinator = self
        sleepReportViewModel.coordinator = self
        navigationController.view.backgroundColor = .backgroundMidnightBlue
    }

    func start() {
        switchFlow()
        let paramsOne = Publishers
            .CombineLatest3(AppState.shared.$hasCompletedOnboarding, AppState.shared.$hasCompletedInfoSections, AppState.shared.$todaySleptDate)
            .removeDuplicates { lhs, rhs in
                lhs.0 == rhs.0 && lhs.1 == rhs.1 && lhs.2 == rhs.2
            }

        let paramsTwo = Publishers
            .CombineLatest(AppState.shared.$lastAlarmOff, AppState.shared.$snoozeAlarmDate)
            .removeDuplicates { lhs, rhs in
                lhs.0 == rhs.0 && lhs.1 == rhs.1
            }

        

        paramsOne.combineLatest(paramsTwo)
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _, _ in
                self?.switchFlow()
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
    
    private func switchFlow() {
        currentCoordinator?.stop()
        currentCoordinator = nil
        let coordinator: Coordinator
        if let date = AppState.shared.todaySleptDate {
            let isTodayOrYesterday = Calendar.current.isDate(date, inSameDayAs: Date()) || Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
            AppState.shared.todaySleptDate = isTodayOrYesterday ? date : nil
        }

        if AppState.shared.hasCompletedOnboarding {
            if sleepTimeViewModel.hasToTurnOffAlarm() {
                coordinator = AlarmCoordinator(navigationController: navigationController, sleepLogViewModel: sleepLogViewModel, sleepReportViewModel: sleepReportViewModel, sleepTimeViewModel: sleepTimeViewModel)
            } else if AppState.shared.snoozeAlarmDate != nil || AppState.shared.todaySleptDate != nil {
                coordinator = SleepingCoordinator(navigationController: navigationController, sleepLogViewModel: sleepLogViewModel, sleepReportViewModel: sleepReportViewModel, sleepTimeViewModel: sleepTimeViewModel, sleptDate: AppState.shared.todaySleptDate)
            } else {
                coordinator = MainTabBarCoordinator(navigationController: navigationController, authViewModel: authViewModel, sleepLogViewModel: sleepLogViewModel, sleepReportViewModel: sleepReportViewModel, timeViewModel: sleepTimeViewModel)
            }
        } else {
            coordinator = OnboardingCoordinator(navigationController: navigationController, hasCompletedInfoSections: AppState.shared.hasCompletedInfoSections)
        }
        currentCoordinator = coordinator
        coordinator.start()
    }
    
    func openSettings(state: SleepSettingsState) {
        let viewController = UIHostingController(rootView: SleepSettingsPage(state: state, viewModel: sleepTimeViewModel, onDismiss: { [weak self] in
            self?.navigationController.setNavigationBarHidden(true, animated: false)
        }))
        navigationController.pushViewController(viewController, animated: true)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setNavigationBarHidden(false, animated: false)
    }
    
    func showEditSleep(for session: SleepSession) {
        let viewController = UIHostingController(
            rootView: AddSleepLogPage(state: .edit(session), onSave: { [weak self] date, start, end in
                try await self?.sleepReportViewModel.updateSleepSession(
                    sessionID: session.id,
                    startTime: start,
                    endTime: end)
            })
        )
        viewController.view.backgroundColor = .clear
        navigationController.present(viewController, animated: true)
    }
}
