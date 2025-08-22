//
//  SleepTimeViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 19.08.2025.
//

import Combine
import Foundation
import SwiftUI

class SleepTimeViewModel: ObservableObject {
    @Published private(set) var sleepTime: Time
    @Published private(set) var wakeTime: Time

    var sleepTimeBinding: Binding<Time> {
        Binding(
            get: { self.sleepTime },
            set: { self.updateSleepTime($0) }
        )
    }

    var wakeTimeBinding: Binding<Time> {
        Binding(
            get: { self.wakeTime },
            set: { self.updateWakeTime($0) }
        )
    }
    
    private let environment: AppEnvironment
    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: HomeCoordinator?

    init(environment: AppEnvironment) {
        self.environment = environment
        
        // initialize from AppState
        self.sleepTime = AppState.shared.sleepTime
        self.wakeTime = AppState.shared.wakeTime
        
        // subscribe to future changes
        AppState.shared.$sleepTime
            .removeDuplicates()
            .assign(to: &$sleepTime)
        
        AppState.shared.$wakeTime
            .removeDuplicates()
            .assign(to: &$wakeTime)
    }
    
    func updateSleepTime(_ time: Time) {
        AppState.shared.sleepTime = time
    }
    
    func updateWakeTime(_ time: Time) {
        AppState.shared.wakeTime = time
    }

    func openSettings(state: SleepSettingsState) {
        coordinator?.openSettings(state: state)
    }
    
    func todayString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "kk_KZ")
        formatter.dateFormat = "EE, d LLL"
        return formatter.string(from: Date()).capitalized
    }
    
    func startSleep() {
        AppState.shared.todaySleptDate = Date()
    }
    
    func timeLeft(for timeType: SleepSettingsState) -> Time {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        guard let todayHour = components.hour,
              let todayMinute = components.minute else {
            return .zero
        }
        var todayTime = Time(hour: todayHour, minute: todayMinute)
        var sleepTime = sleepTime
        var wakeTime = wakeTime
        
        switch timeType {
        case .sleep:
            if sleepTime > wakeTime {
                let diff = Time.twentyFour.totalMinutes - sleepTime.totalMinutes
                sleepTime = .zero
                wakeTime = .init(minutes: diff + wakeTime.totalMinutes)
                todayTime = .init(minutes: diff + todayTime.totalMinutes)
            }
            if todayTime > sleepTime {
                if todayTime < wakeTime {
                    return Time(minutes: sleepTime.totalMinutes - todayTime.totalMinutes)
                } else {
                    return Time(minutes: 24 * 60 + sleepTime.totalMinutes - todayTime.totalMinutes)
                }
            } else {
                return Time(minutes: sleepTime.totalMinutes - todayTime.totalMinutes)
            }
        case .wake:
            if todayTime < wakeTime {
                return Time(minutes: wakeTime.totalMinutes - todayTime.totalMinutes)
            } else {
                return Time(minutes: 24 * 60 + wakeTime.totalMinutes - todayTime.totalMinutes)
            }
        }
    }
}
