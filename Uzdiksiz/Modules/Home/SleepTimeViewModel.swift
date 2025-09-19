//
//  SleepTimeViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 19.08.2025.
//

import Combine
import Foundation
import SwiftUI
import AlarmKit

protocol SettingsNavigator: NSObjectProtocol {
    func openSettings(state: SleepSettingsState)
}

class SleepTimeViewModel: ObservableObject {
    @Published private(set) var sleepTime: Time
    @Published private(set) var wakeTime: Time
    @Published private(set) var isNotificationOn: Bool
    @Published private(set) var isAlarmOn: Bool
    @Published private(set) var remindInAdvance: Time
    @Published private(set) var notificationPermissionGranted: Bool? = nil
    @Published private(set) var alarmPermissionGranted: Bool? = nil

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
    static let alarmID = "dailyAlarm"
    private let alarmDurationSeconds = 300
    private let alarmIntervalSeconds = 5
    var alarmIDs: [String] {
        (0..<(alarmDurationSeconds/alarmIntervalSeconds)).map { "\(Self.alarmID)\($0)" }
    }

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

    var isAlarmOnBinding: Binding<Bool> {
        Binding(
            get: { self.isAlarmOn },
            set: { self.updateIsAlarmOn($0) }
        )
    }

    var remindInAdvanceBinding: Binding<Time> {
        Binding(
            get: { self.remindInAdvance },
            set: { self.updateRemindInAdvance($0) }
        )
    }

    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: SettingsNavigator?

    init() {
        self.sleepTime = AppState.shared.sleepTime
        self.wakeTime = AppState.shared.wakeTime
        self.isNotificationOn = AppState.shared.isNotificationOn
        self.isAlarmOn = AppState.shared.isAlarmOn
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
        
        AppState.shared.$isAlarmOn
            .removeDuplicates()
            .assign(to: &$isAlarmOn)
        
        AppState.shared.$remindInAdvance
            .removeDuplicates()
            .assign(to: &$remindInAdvance)
        AppState.shared.$notificationIsPermitted.sink { granted in
            self.updatePermission(granted)
        }.store(in: &cancellables)
        AppState.shared.$alarmIsPermitted.sink { granted in
            self.updateAlarmPermission(granted)
        }.store(in: &cancellables)
    }
        
    func updatePermission(_ granted: Bool) {
        self.notificationPermissionGranted = granted
        if granted, self.isNotificationOn {
            self.updateDailyNotification()
        }
        if #unavailable(iOS 26.0), granted, self.isAlarmOn {
            self.updateAlarm()
        }
    }
    
    func updateAlarmPermission(_ granted: Bool) {
        if #available(iOS 26.0, *), granted, self.isAlarmOn {
            self.alarmPermissionGranted = granted
            if granted, self.isAlarmOn {
                self.updateAlarm()
            }
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
        updateAlarm()
    }
    
    func updateIsNotificationOn(_ isOn: Bool) {
        AppState.shared.isNotificationOn = isOn
        updateDailyNotification()
    }

    func updateIsAlarmOn(_ isOn: Bool) {
        AppState.shared.isAlarmOn = isOn
        updateAlarm()
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
    
    func turnOffAlarm() {
        AppState.shared.lastAlarmOff = Date()
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: alarmIDs)
        center.removeDeliveredNotifications(withIdentifiers: alarmIDs)
        print("🔕 Alarm stopped by user")
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
    
    func updateAlarm() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: alarmIDs)
        if #available(iOS 26.0, *) {
            let id = getAlarmID()
            Task {
                do {
                    let alarm = try AlarmManager.shared.alarms.first(where: { $0.id == id })
                    if !isAlarmOn {
                        if let alarm {
                            try AlarmManager.shared.cancel(id: alarm.id)
                            print("ALARM UPDATE \(wakeTime.toString()): DELETE SUCCESS")
                        }
                        return
                    }
                    if let alarm {
                        if let schedule = alarm.schedule, case let Alarm.Schedule.relative(relativeSchedule) = schedule {
                            if relativeSchedule.time.hour == wakeTime.hour, relativeSchedule.time.minute == wakeTime.minute {
                                return
                            }
                        }
                        try AlarmManager.shared.cancel(id: alarm.id)
                    }
                    let alert = AlarmPresentation.Alert(
                        title: "Uzdiksiz Ерте!",
                        stopButton: .init(text: "Тоқтату", textColor: .red, systemImageName: "stop.fill")
                    )
                    let presentation = AlarmPresentation(alert: alert)
                    let attributes = AlarmAttributes<CustomAlarmAttributes>(presentation: presentation, metadata: .init(), tintColor: .orange)
                    let schedule = Alarm.Schedule.relative(.init(time: .init(hour: wakeTime.hour, minute: wakeTime.minute), repeats: .weekly([.monday, .tuesday, .thursday, .wednesday, .friday, .saturday, .sunday])))
                    let config = AlarmManager.AlarmConfiguration(schedule: schedule, attributes: attributes)

                    _ = try await AlarmManager.shared.schedule(id: id, configuration: config)
                    print("ALARM UPDATE \(wakeTime.toString()): UPDATE SUCCESS")
                } catch {
                    print("ALARM UPDATE \(wakeTime.toString()): ERROR \(error.localizedDescription)")
                }
            }
        } else {
            guard isAlarmOn, notificationPermissionGranted == true else {
                return
            }
            var referenceDate = wakeTime.date
            if referenceDate <= Date() {
                referenceDate = Calendar.current.date(byAdding: .day, value: 1, to: referenceDate) ?? referenceDate
            }

            for (i, id) in alarmIDs.enumerated() {
                let content = UNMutableNotificationContent()
                content.title = "Оятқышты өшіру үшін басыңыз"
                content.body = "Ояну уақыты"
                content.interruptionLevel = .critical
                content.sound = UNNotificationSound(named: UNNotificationSoundName("radar.mp3"))
                var dateComponents = DateComponents(calendar: Calendar.current)
                dateComponents.second = alarmIntervalSeconds
                guard let nextTriggerDate = dateComponents.calendar?.date(byAdding: dateComponents, to: referenceDate),
                      let nextTriggerDateCompnents = dateComponents.calendar?.dateComponents([.second, .hour, .minute], from: nextTriggerDate) else {
                    return
                }
                referenceDate = nextTriggerDate

                print("Alarm set:", nextTriggerDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: nextTriggerDateCompnents, repeats: true)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    func getAlarmID() -> UUID {
        let key = "wake_alarm_id"
        if let saved = UserDefaults.standard.string(forKey: key),
           let uuid = UUID(uuidString: saved) {
            return uuid
        } else {
            let new = UUID()
            UserDefaults.standard.set(new.uuidString, forKey: key)
            return new
        }
    }

    func hasToTurnOffAlarm() -> Bool {
        let wakeStart = AppState.shared.wakeTime.date
        let wakeEnd = Calendar.current.date(byAdding: .second, value: alarmDurationSeconds, to: AppState.shared.wakeTime.date)!
        let lastAlarmOff = AppState.shared.lastAlarmOff
        
        let isWithinWindow = (wakeStart ... wakeEnd).contains(Date())
        let hasNotTurnedOffAlarmToday: Bool = {
            guard let off = lastAlarmOff else { return true }
            return off < wakeStart || off > wakeEnd
        }()
        
        return isWithinWindow && hasNotTurnedOffAlarmToday
    }
}
