//
//  Date+Extensions.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 28.08.2025.
//

import Foundation

extension Date {
    var dateKey: Int32 {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        guard let y = components.year, let m = components.month, let d = components.day else {
            return 0
        }
        return Int32(y * 10_000 + m * 100 + d) // format: yyyyMMdd
    }
}
