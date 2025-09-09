//
//  SleepStatsChartData.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 09.09.2025.
//

import Foundation

struct SleepStatsChartData {
    let type: SleepStatsChartType
    let values: [(date: Date, score: Int?)]
    let start: Date
    let end: Date
    init(start: Date, end: Date, type: SleepStatsChartType, reports: [SleepReport]) {
        self.type = type
        self.start = start
        self.end = end
        let calendar = Calendar.current
        if let days = calendar.dateComponents([.day], from: start, to: end).day {
            let reportByDate = Dictionary(uniqueKeysWithValues: reports.map {
                (calendar.startOfDay(for: $0.date), $0)
            })
            
            values = (0...days).compactMap { offset in
                guard var day = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
                day = calendar.startOfDay(for: day)
                if let report = reportByDate[day] {
                    switch type {
                    case .quality:
                        return (day, report.quality())
                    case .duration:
                        return (day, report.totalSleepMinutes)
                    case .startTime:
                        if let first = report.intervals.min(by: { $0.end.totalMinutes < $1.end.totalMinutes }) {
                            var startMinutes = first.start.totalMinutes
                            if let last = report.intervals.max(by: { $0.end.totalMinutes < $1.end.totalMinutes }) {
                                let endMinutes = last.end.totalMinutes
                                if startMinutes > endMinutes {
                                    startMinutes -= 24 * 60
                                }
                            }
                            return (day, startMinutes)
                        }
                        return (day, nil)

                    case .endTime:
                        let minGap = 60
                        let sorted = report.intervals.sorted(by: { $0.end.totalMinutes < $1.end.totalMinutes })
                        for (i, interval) in sorted.enumerated() {
                            if i < sorted.count - 1 {
                                let currentEnd = interval.end.totalMinutes
                                let nextStart = sorted[i + 1].start.totalMinutes
                                let gap = nextStart >= currentEnd
                                    ? (nextStart - currentEnd)
                                    : (nextStart + 24 * 60 - currentEnd) // crossed midnight
                                if gap >= minGap {
                                    return (day, currentEnd)
                                }
                            } else {
                                // If it's the last interval, take its end as the wake time
                                return (day, interval.end.totalMinutes)
                            }
                        }
                        return (day, nil)
                    case .startAndEnd:
                        return (day, nil) // placeholder
                    }
                } else {
                    return (day, nil)
                }
            }
        } else {
            values = []
        }
    }
    
    var maxScore: Int { values.compactMap(\.score).max() ?? 0 }
    var minScore: Int { values.compactMap(\.score).min() ?? 0 }
    var avgScore: Int {
        let scores = values.compactMap(\.score)
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / scores.count
    }
}
