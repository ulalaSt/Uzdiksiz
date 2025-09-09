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
        formatter.locale = Locale(identifier: "kk_KZ") // or current
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        let startString = formatter.string(from: self)
        let endString = formatter.string(from: end)
        return "\(startString) - \(endString)"
    }
}

struct SleepStatsTrendsListView: View {
    let currentRange: SleepStatsRange
    @State var currentDateRange: SleepStatsDateRange
    @ObservedObject var reportViewModel: SleepReportViewModel
    init(currentRange: SleepStatsRange, reportViewModel: SleepReportViewModel) {
        self.currentRange = currentRange
        self.reportViewModel = reportViewModel
        let calendar = Calendar.current
        let today = Date()
        let interval: DateInterval
        switch currentRange {
        case .weekly:
            interval = calendar.dateInterval(of: .weekOfYear, for: today)!
        case .monthly:
            interval = calendar.dateInterval(of: .month, for: today)!
        case .other:
            interval = calendar.dateInterval(of: .weekOfYear, for: today)!
        }
        self._currentDateRange = .init(
            initialValue: SleepStatsDateRange(start: interval.start, end: interval.end)
        )
    }
    
    var body: some View {
        VStack(spacing: 24) {
            rangeNavigator
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if case let .loaded(reports) = reportViewModel.sleepReports {
                        let filtered = reports.filter { r in
                            let d = r.date
                            return d >= currentDateRange.startDay && d <= currentDateRange.endDay
                        }
                        if !filtered.isEmpty {
                            SleepStatsChartSectionView(start: currentDateRange.startDay, end: currentDateRange.endDay, reports: filtered, type: .quality)
                            SleepStatsChartSectionView(start: currentDateRange.startDay, end: currentDateRange.endDay, reports: filtered, type: .duration)
                            SleepStatsChartSectionView(start: currentDateRange.startDay, end: currentDateRange.endDay, reports: filtered, type: .startTime)
                            SleepStatsChartSectionView(start: currentDateRange.startDay, end: currentDateRange.endDay, reports: filtered, type: .endTime)
                            SleepStatsChartSectionView(start: currentDateRange.startDay, end: currentDateRange.endDay, reports: filtered, type: .startAndEnd)
                        } else {
                            Text("Бұл кезеңге деректер жоқ")
                                .foregroundStyle(.secondary)
                                .padding()
                        }
                    } else {
                        ProgressView("Жүктелуде…")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .onChange(of: currentRange) { newRange in
            let calendar = Calendar.current
            let today = Date()
            let interval: DateInterval
            switch newRange {
            case .weekly:
                interval = calendar.dateInterval(of: .weekOfYear, for: today)!
            case .monthly:
                interval = calendar.dateInterval(of: .month, for: today)!
            case .other:
                interval = calendar.dateInterval(of: .weekOfYear, for: today)!
            }
            currentDateRange = SleepStatsDateRange(start: interval.start, end: interval.end)
        }
    }
    
    @ViewBuilder
    var rangeNavigator: some View {
        if currentRange == .other {
            DateRangeSelectorButton(currentDateRange: $currentDateRange)
        } else {
            HStack {
                Button {
                    shiftRange(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.callout.weight(.semibold))
                        .frame(width: 22, height: 22)
                }
                Spacer()
                Text(currentDateRange.startDay.formattedRange(to: currentDateRange.endDay))
                    .font(.callout.weight(.semibold))
                Spacer()
                Button {
                    shiftRange(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.callout.weight(.semibold))
                        .frame(width: 22, height: 22)
                }
            }
        }
    }
    
    private func shiftRange(by value: Int) {
        let calendar = Calendar.current
        switch currentRange {
        case .weekly:
            if let newStart = calendar.date(byAdding: .weekOfYear, value: value, to: currentDateRange.startDay),
               let newEnd = calendar.date(byAdding: .weekOfYear, value: value, to: currentDateRange.endDay) {
                currentDateRange = SleepStatsDateRange(start: newStart, end: newEnd)
            }
        case .monthly:
            if let newStart = calendar.date(byAdding: .month, value: value, to: currentDateRange.startDay),
               let newEnd = calendar.date(byAdding: .month, value: value, to: currentDateRange.endDay) {
                currentDateRange = SleepStatsDateRange(start: newStart, end: newEnd)
            }
        case .other:
            break
        }
    }
}
