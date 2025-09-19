//
//  SleepStatsTrendsListView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 08.09.2025.
//

import SwiftUI

extension Date {
    func formattedRange(to end: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "kk_KZ") // or Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        formatter.timeZone = .current
        
        let actualLastDay = Calendar.current.date(byAdding: .day, value: -1, to: end) ?? end
        
        let startString = formatter.string(from: self)
        let endString = formatter.string(from: actualLastDay)
        
        return "\(startString) - \(endString)"
    }
}

struct SleepStatsTrendsListView: View {
    let reports: [SleepReport]
    let currentInterval: DateInterval
    init(reports: [SleepReport], currentInterval: DateInterval) {
        self.reports = reports
        self.currentInterval = currentInterval
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !reports.isEmpty {
                let actualLastDay = Calendar.current.date(byAdding: .day, value: -1, to: currentInterval.end) ?? currentInterval.end
                SleepStatsChartSectionView(start: currentInterval.start, end: actualLastDay, reports: reports, type: .quality)
                SleepStatsChartSectionView(start: currentInterval.start, end: actualLastDay, reports: reports, type: .duration)
                SleepStatsChartSectionView(start: currentInterval.start, end: actualLastDay, reports: reports, type: .startTime)
                SleepStatsChartSectionView(start: currentInterval.start, end: actualLastDay, reports: reports, type: .endTime)
                SleepStatsChartSectionView(start: currentInterval.start, end: actualLastDay, reports: reports, type: .startAndEnd)
            } else {
                Text("Бұл кезеңге деректер жоқ")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .padding(.bottom, 32)
    }
}
