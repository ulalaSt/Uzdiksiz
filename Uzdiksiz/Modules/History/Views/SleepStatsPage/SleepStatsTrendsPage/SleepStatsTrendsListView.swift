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
    let range: SleepStatsRange
    @State var currentDateRange: SleepStatsDateRange
    
    init(range: SleepStatsRange) {
        self.range = range
        let calendar = Calendar.current
        let today = Date()
        let interval: DateInterval
        switch range {
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
                    // content
                }
                .padding(.bottom, 32)
            }
        }
    }
    
    @ViewBuilder
    var rangeNavigator: some View {
        if range == .other {
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
                Text(currentDateRange.start.formattedRange(to: currentDateRange.end))
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
        switch range {
        case .weekly:
            if let newStart = calendar.date(byAdding: .weekOfYear, value: value, to: currentDateRange.start),
               let newEnd = calendar.date(byAdding: .weekOfYear, value: value, to: currentDateRange.end) {
                currentDateRange = SleepStatsDateRange(start: newStart, end: newEnd)
            }
        case .monthly:
            if let newStart = calendar.date(byAdding: .month, value: value, to: currentDateRange.start),
               let newEnd = calendar.date(byAdding: .month, value: value, to: currentDateRange.end) {
                currentDateRange = SleepStatsDateRange(start: newStart, end: newEnd)
            }
        case .other:
            break
        }
    }
}
