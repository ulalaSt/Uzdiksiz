//
//  AppStorage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 20.08.2025.
//

import Foundation

class AppStorage {
    @Defaults(AppStorageKeys.hasCompletedOnboarding, defaultValue: false)
    var hasCompletedOnboarding: Bool
    
    @Defaults(AppStorageKeys.hasCompletedInfoSections, defaultValue: false)
    var hasCompletedInfoSections: Bool
    
    @Defaults(AppStorageKeys.sleepTime, defaultValue: Time(hour: 22, minute: 0))
    var sleepTime: Time
    
    @Defaults(AppStorageKeys.wakeTime, defaultValue: Time(hour: 6, minute: 0))
    var wakeTime: Time
    
    @Defaults(AppStorageKeys.isNotificationOn, defaultValue: true)
    var isNotificationOn: Bool
    
    @Defaults(AppStorageKeys.isAlarmOn, defaultValue: true)
    var isAlarmOn: Bool
    
    @DefaultsOptional(AppStorageKeys.lastAlarmOff)
    var lastAlarmOff: Date?
    
    @DefaultsOptional(AppStorageKeys.snoozeAlarmDate)
    var snoozeAlarmDate: Date?
    
    @Defaults(AppStorageKeys.remindInAdvance, defaultValue: Time(hour: 0, minute: 30))
    var remindInAdvance: Time

    @DefaultsOptional(AppStorageKeys.todaySleptDate)
    var todaySleptDate: Date?
}

enum AppStorageKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let hasCompletedInfoSections = "hasCompletedInfoSections"
    static let sleepTime = "sleepTime"
    static let wakeTime = "wakeTime"
    static let isNotificationOn = "isNotificationOn"
    static let isAlarmOn = "isAlarmOn"
    static let lastAlarmOff = "lastAlarmOff"
    static let snoozeAlarmDate = "snoozeAlarmDate"
    static let remindInAdvance = "remindInAdvance"
    static let todaySleptDate = "todaySleptDate"
}
