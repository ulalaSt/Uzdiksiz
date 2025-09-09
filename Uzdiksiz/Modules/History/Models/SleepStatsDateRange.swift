//
//  SleepStatsDateRange.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 08.09.2025.
//
import Foundation

struct SleepStatsDateRange: Equatable, Hashable {
    let startDay: Date
    let endDay: Date
    
    init(start: Date, end: Date) {
        self.startDay = Calendar.current.startOfDay(for: start)
        self.endDay = Calendar.current.startOfDay(for: end)
    }
}
