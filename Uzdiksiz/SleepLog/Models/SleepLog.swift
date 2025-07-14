//
//  SleepLog.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 13.07.2025.
//

import Foundation
import FirebaseCore

struct SleepLog: Codable {
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
