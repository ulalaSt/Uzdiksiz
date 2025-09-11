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
    let state: SleepStatsState
    @State var dateInterval: DateInterval
    @State var shift: Int = 0
    @ObservedObject var reportViewModel: SleepReportViewModel
    init(state: SleepStatsState, reportViewModel: SleepReportViewModel) {
        self.state = state
        self.reportViewModel = reportViewModel
        self._dateInterval = .init(initialValue: Calendar.current.dateInterval(of: .weekOfYear, for: Date()) ?? .init())
    }
    
    var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    
    var currentInterval: DateInterval {
        switch state {
        case .weekly:
            guard let shiftedDate = calendar.date(byAdding: .weekOfYear, value: shift, to: Date()),
                  let week = calendar.dateInterval(of: .weekOfYear, for: shiftedDate) else {
                return .init()
            }
            return week
        case .monthly:
            guard let shiftedDate = calendar.date(byAdding: .month, value: shift, to: Date()),
                  let month = calendar.dateInterval(of: .month, for: shiftedDate) else {
                return .init()
            }
            return month
        case .custom:
            return dateInterval
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            rangeNavigator
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    if case let .loaded(reports) = reportViewModel.sleepReports {
                        let calendar = Calendar.current
                        let actualLastDay = Calendar.current.date(byAdding: .day, value: -1, to: currentInterval.end) ?? currentInterval.end

                        let filtered = reports.filter { r in
                            calendar.compare(r.date, to: currentInterval.start, toGranularity: .day) != .orderedAscending &&
                            calendar.compare(r.date, to: actualLastDay, toGranularity: .day) != .orderedDescending
                        }
                        if !filtered.isEmpty {
                            SleepStatsChartSectionView(start: currentInterval.start, end: actualLastDay, reports: filtered, type: .quality)
                            SleepStatsChartSectionView(start: currentInterval.start, end: actualLastDay, reports: filtered, type: .duration)
                            SleepStatsChartSectionView(start: currentInterval.start, end: actualLastDay, reports: filtered, type: .startTime)
                            SleepStatsChartSectionView(start: currentInterval.start, end: actualLastDay, reports: filtered, type: .endTime)
                            SleepStatsChartSectionView(start: currentInterval.start, end: actualLastDay, reports: filtered, type: .startAndEnd)
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
    }
    
    @ViewBuilder
    var rangeNavigator: some View {
        if state == .custom {
            DateRangeSelectorButton(dateInterval: $dateInterval)
        } else {
            HStack {
                Button {
                    shift-=1
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.callout.weight(.semibold))
                        .frame(width: 22, height: 22)
                }
                Spacer()
                Text(currentInterval.start.formattedRange(to: currentInterval.end))
                    .font(.callout.weight(.semibold))
                Spacer()
                Button {
                    shift+=1
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.callout.weight(.semibold))
                        .frame(width: 22, height: 22)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
