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
    @Published private(set) var isNotificationOn: Bool
    @Published private(set) var remindInAdvance: Time
    @Published private(set) var notificationPermissionGranted: Bool? = nil
    
    var notificationTime: Time {
        var totalMinutes = sleepTime.totalMinutes - remindInAdvance.totalMinutes
        if totalMinutes < 0 {
            totalMinutes += 24 * 60
        }
        
        let adjustedHour = totalMinutes / 60
        let adjustedMinute = totalMinutes % 60
        return Time(hour: adjustedHour, minute: adjustedMinute)
    }
    
    static let sleepNotificationID = "dailySleepNotification"
    static let quotes: [String] = [
        "Ерте жатып, ерте тұру адамды сау, бай және ақылды етеді (Бенджамин Франклин)",
        "Ұйықтап алатын уақытты ешқашан зая кетірме (Фрэнк Х. Найт)",
        "Түнде қиын мәселе ұйқы комитеті жұмыс істегеннен кейін таңертең шешілетіні әдеттегі тәжірибе (Джон Стейнбек)",
        "Ерте тұрған еркектің ырысы артық, ерте тұрған әйелдің бір ісі артық (Мақал)",
        "Таңғы ой – кешкі ойдан дана (Орыс даналығы)",
        "Ұйқы – ең жақсы медитация (Далай-лама)"
    ]
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
    
    var isNotificationOnBinding: Binding<Bool> {
        Binding(
            get: { self.isNotificationOn },
            set: { self.updateIsNotificationOn($0) }
        )
    }

    var remindInAdvanceBinding: Binding<Time> {
        Binding(
            get: { self.remindInAdvance },
            set: { self.updateRemindInAdvance($0) }
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
        self.isNotificationOn = AppState.shared.isNotificationOn
        self.remindInAdvance = AppState.shared.remindInAdvance

        // subscribe to future changes
        AppState.shared.$sleepTime
            .removeDuplicates()
            .assign(to: &$sleepTime)
        
        AppState.shared.$wakeTime
            .removeDuplicates()
            .assign(to: &$wakeTime)
        
        AppState.shared.$isNotificationOn
            .removeDuplicates()
            .assign(to: &$isNotificationOn)
        
        AppState.shared.$remindInAdvance
            .removeDuplicates()
            .assign(to: &$remindInAdvance)
        AppState.shared.$notificationIsPermitted.sink { granted in
            self.updatePermission(granted)
        }.store(in: &cancellables)
    }
        
    func updatePermission(_ granted: Bool) {
        self.notificationPermissionGranted = granted
        if granted, self.isNotificationOn {
            self.updateDailyNotification()
        }
    }
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    func updateSleepTime(_ time: Time) {
        AppState.shared.sleepTime = time
        updateDailyNotification()
    }
    
    func updateWakeTime(_ time: Time) {
        AppState.shared.wakeTime = time
    }
    
    func updateIsNotificationOn(_ isOn: Bool) {
        AppState.shared.isNotificationOn = isOn
        updateDailyNotification()
    }

    func updateRemindInAdvance(_ time: Time) {
        AppState.shared.remindInAdvance = time
        updateDailyNotification()
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
    
    func updateDailyNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.sleepNotificationID])
        guard isNotificationOn, notificationPermissionGranted == true else {
            return
        }

        let content = UNMutableNotificationContent()
        let advText = remindInAdvance.string
        content.title = "🌙 Ұйықтауға \(advText) қалды"
        content.body = Self.quotes.randomElement() ?? ""
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = notificationTime.hour
        dateComponents.minute = notificationTime.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: Self.sleepNotificationID,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
