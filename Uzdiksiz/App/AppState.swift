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

    @Published
    var isNotificationOn: Bool

    @Published
    var isAlarmOn: Bool

    @Published
    var lastAlarmOff: Date?

    @Published
    var remindInAdvance: Time
    
    @Published
    var notificationIsPermitted: Bool
    
    @Published
    var alarmIsPermitted: Bool
    
    @Published
    var todaySleptDate: Date?
    
    private var cancellables = Set<AnyCancellable>()
        
    private init(storage: AppStorage) {
        self.storage = storage
        self.hasCompletedOnboarding = storage.hasCompletedOnboarding
        self.hasCompletedInfoSections = storage.hasCompletedInfoSections
        self.sleepTime = storage.sleepTime
        self.wakeTime = storage.wakeTime
        self.todaySleptDate = storage.todaySleptDate
        self.isNotificationOn = storage.isNotificationOn
        self.isAlarmOn = storage.isAlarmOn
        self.lastAlarmOff = storage.lastAlarmOff
        self.remindInAdvance = storage.remindInAdvance
        self.notificationIsPermitted = false
        self.alarmIsPermitted = false
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
        
        $isNotificationOn.sink {
            storage.isNotificationOn = $0
        }.store(in: &cancellables)
        
        $isAlarmOn.sink {
            storage.isAlarmOn = $0
        }.store(in: &cancellables)
        
        $lastAlarmOff.sink {
            storage.lastAlarmOff = $0
        }.store(in: &cancellables)
        
        $remindInAdvance.sink {
            storage.remindInAdvance = $0
        }.store(in: &cancellables)
        
        $todaySleptDate.sink {
            storage.todaySleptDate = $0
        }.store(in: &cancellables)
    }
}

