//
//  AppState.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 04.08.2025.
//

import Combine
import Foundation

final class AppState: ObservableObject {
    @Published var user: Loadable<AppUser>
    @Published private(set) var hasCompletedOnboarding: Bool
    private var cancellables = Set<AnyCancellable>()
    
    init(user: Loadable<AppUser>) {
        self.user = user
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: AppStateKeys.hasCompletedOnboarding)
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .map { _ in UserDefaults.standard.bool(forKey: AppStateKeys.hasCompletedOnboarding) }
            .removeDuplicates()
            .sink { [weak self] newValue in
                self?.hasCompletedOnboarding = newValue
            }
            .store(in: &cancellables)
    }
    
    func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: AppStateKeys.hasCompletedOnboarding)
    }
}

enum AppStateKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
}
