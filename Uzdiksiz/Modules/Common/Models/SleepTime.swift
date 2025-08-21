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
    
    var date: Date {
        Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
    }
    
    var isPositive: Bool {
        hour >= 0 && minute >= 0
    }
}
