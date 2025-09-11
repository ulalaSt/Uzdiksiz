//
//  HomeViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 07.08.2025.
//

final class HomeViewModel {
    weak var coordinator: HomeCoordinator?
    private let appState: AppState
    private let environment: AppEnvironment

    init(appState: AppState, environment: AppEnvironment) {
        self.appState = appState
        self.environment = environment
    }
}
