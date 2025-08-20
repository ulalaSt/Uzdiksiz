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
    
    func toMinutes() -> Int {
        hour * 60 + minute
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
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
    }
    
    var date: Date {
        Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
    }
    
    var isPositive: Bool {
        hour >= 0 && minute >= 0
    }
}
