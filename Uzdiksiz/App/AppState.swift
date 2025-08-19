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
    @Published private(set) var hasCompletedInfoSections: Bool
    private var cancellables = Set<AnyCancellable>()
    
    init(user: Loadable<AppUser>) {
        self.user = user
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: AppStateKeys.hasCompletedOnboarding)
        self.hasCompletedInfoSections = UserDefaults.standard.bool(forKey: AppStateKeys.hasCompletedInfoSections)
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let onboarding = UserDefaults.standard.bool(forKey: AppStateKeys.hasCompletedOnboarding)
                let infoSections = UserDefaults.standard.bool(forKey: AppStateKeys.hasCompletedInfoSections)
                
                if self.hasCompletedOnboarding != onboarding {
                    self.hasCompletedOnboarding = onboarding
                }
                if self.hasCompletedInfoSections != infoSections {
                    self.hasCompletedInfoSections = infoSections
                }
            }
            .store(in: &cancellables)
    }
    
    func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: AppStateKeys.hasCompletedOnboarding)
    }
    
    func markInfoSectionsCompleted() {
        UserDefaults.standard.set(true, forKey: AppStateKeys.hasCompletedInfoSections)
    }
}

enum AppStateKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let hasCompletedInfoSections = "hasCompletedInfoSections"
}
