//
//  SleepLog.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 13.07.2025.
//

import Foundation
import FirebaseCore

struct SleepLog: Codable, Equatable, Identifiable {
    var id: String { documentID }
    var documentID: String
    var date: String
    var sleepTime: String
    var wakeTime: String
    var expectedWakeTime: String
    var reasonId: Int?
    var customReason: String?
    var createdAt: Date
}

extension SleepLog {
    func toDict() -> [String: Any] {
        return [
            "date": date,
            "sleepTime": sleepTime,
            "wakeTime": wakeTime,
            "expectedWakeTime": expectedWakeTime,
            "reasonId": reasonId as Any,
            "customReason": customReason as Any,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
}

extension SleepLog {
    /// Returns the duration between sleepTime and wakeTime as (hours, minutes).
    var durationHM: (hour: Int, minute: Int)? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let sleepDate = formatter.date(from: sleepTime),
              let wakeDate  = formatter.date(from: wakeTime) else {
            return nil
        }
        
        var interval = wakeDate.timeIntervalSince(sleepDate)
        if interval < 0 {
            // crossed midnight → add 24h
            interval += 24 * 60 * 60
        }
        
        let minutes = Int(interval) / 60
        return (minutes / 60, minutes % 60)
    }
    
    /// Returns a string like "6сағ 33мин" or "45мин"
    var durationString: String {
        guard let (h, m) = durationHM else { return "—" }
        if h > 0 {
            return "\(h)сағ \(m)мин"
        } else {
            return "\(m)мин"
        }
    }
}
