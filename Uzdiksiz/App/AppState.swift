//
//  AppState.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 04.08.2025.
//

import Combine
import Foundation

final class AppState: ObservableObject {
    static let shared: AppState = AppState(storage: AppStorage())
    let storage: AppStorage

    @Published
    var hasCompletedOnboarding: Bool

    @Published
    var hasCompletedInfoSections: Bool
    
    @Published
    var sleepTime: Time
    
    @Published
    var wakeTime: Time
        
    private var cancellables = Set<AnyCancellable>()
        
    init(storage: AppStorage) {
        self.storage = storage
        self.hasCompletedOnboarding = storage.hasCompletedOnboarding
        self.hasCompletedInfoSections = storage.hasCompletedInfoSections
        self.sleepTime = storage.sleepTime
        self.wakeTime = storage.wakeTime
        
        $hasCompletedOnboarding.sink {
            storage.hasCompletedOnboarding = $0
        }.store(in: &cancellables)

        $hasCompletedInfoSections.sink {
            storage.hasCompletedInfoSections = $0
        }.store(in: &cancellables)

        $sleepTime.sink {
            storage.sleepTime = $0
        }.store(in: &cancellables)

        $wakeTime.sink {
            storage.wakeTime = $0
        }.store(in: &cancellables)
    }
}

