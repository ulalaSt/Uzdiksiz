//
//  SleepTime.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 20.08.2025.
//

import Foundation

struct Time: Comparable, UserDefaultsRepresentableDecoded {
    let hour: Int
    let minute: Int
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.hour < rhs.hour && lhs.minute < rhs.minute
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
    
    /// Convert to minutes since midnight
    var totalMinutes: Int {
        hour * 60 + minute
    }
    
    /// Normalize hours/minutes into 0...23 and 0...59
    func normalized() -> Time {
        var h = hour % 24
        if h < 0 { h += 24 }
        var m = minute % 60
        if m < 0 { m += 60 }
        return Time(hour: h, minute: m)
    }
    
    static func fromMinutes(_ minutes: Int) -> Time {
        let h = (minutes / 60) % 24
        let m = minutes % 60
        return Time(hour: h, minute: m)
    }

    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    init(minutes: Int) {
        self.hour = minutes / 60
        self.minute = minutes % 60
    }
    
    static let twentyFour: Time = .init(hour: 24, minute: 0)
    static let twentyTwo: Time = .init(hour: 22, minute: 0)
    static let five: Time = .init(hour: 5, minute: 0)
    static let zero: Time = .init(hour: 0, minute: 0)
    
    func toString(isDiff: Bool = false) -> String {
        if isDiff {
            if isPositive {
                return "\(hour)cағ \(minute)мин қалды"
            } else {
                return "\(hour)cағ \(minute)мин өтті"
            }
        } else {
            return String(format: "%02d:%02d", hour, minute)
        }
    }
    
    var string: String {
        var parts: [String] = []
        
        if hour > 0 {
            parts.append("\(hour)сағ")
        }
        if minute > 0 {
            parts.append("\(minute)мин")
        }
        
        // Егер екеуі де 0 болса → 0мин деп шығару
        if parts.isEmpty {
            return "0мин"
        }
        
        return parts.joined(separator: " ")
    }
    
    var date: Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components) ?? now
    }
    
    var isPositive: Bool {
        hour >= 0 && minute >= 0
    }
    
    static var current: Time {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        return Time(hour: hour, minute: minute)
    }
    
    var timeRemaining: Time {
        let now = Date()
        var target = AppState.shared.wakeTime.date
        if now > target { // if already past 5 AM, calculate for next day
            target = Calendar.current.date(byAdding: .day, value: 1, to: target)!
        }
        let diff = Calendar.current.dateComponents([.hour, .minute], from: now, to: target)
        return Time(hour: diff.hour ?? 0, minute: diff.minute ?? 0)
    }
}
