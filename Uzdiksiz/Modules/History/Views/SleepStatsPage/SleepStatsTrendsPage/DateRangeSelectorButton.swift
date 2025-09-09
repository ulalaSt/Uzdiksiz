//
//  DateRangeSelectorButton.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 08.09.2025.
//

import SwiftUI

struct DateRangeSelectorButton: View {
    @Binding var currentDateRange: SleepStatsDateRange
    
    @State private var showDateRangePicker = false
    @State private var dates: Set<DateComponents>
    
    init(currentDateRange: Binding<SleepStatsDateRange>) {
        self._currentDateRange = currentDateRange
        self._dates = State(initialValue: filledRange(selectedDates: [
            Calendar.current.dateComponents([
                .calendar, .era, .year, .month, .day
            ], from: currentDateRange.wrappedValue.startDay),
            Calendar.current.dateComponents([
                .calendar, .era, .year, .month, .day
            ], from: currentDateRange.wrappedValue.endDay)
        ]))
    }
    
    var body: some View {
        Button {
            preloadDates(with: currentDateRange.startDay, end: currentDateRange.endDay)
            showDateRangePicker = true
        } label: {
            HStack(spacing: 10) {
                Text(currentDateRange.startDay.formattedRange(to: currentDateRange.endDay))
                    .font(.callout.weight(.semibold))
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
                    .frame(width: 22, height: 22)
            }
            .foregroundColor(.textSoftWhite)
            .padding(8)
            .padding(.leading, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .onChange(of: currentDateRange) { newValue in
            preloadDates(with: newValue.startDay, end: newValue.endDay)
        }
        .popover(isPresented: $showDateRangePicker) {
            ZStack {
                Color.backgroundDeepNavy.ignoresSafeArea()
                VStack(spacing: 16) {
                    MultiDatePicker("Диапазон таңдау", selection: datesBinding)
                        .colorScheme(.dark)
                        .preferredColorScheme(.dark)
                        .frame(height: 350)
                        .environment(\.locale, Locale(identifier: "kk_KZ"))
                    HStack {
                        Button("Болдырмау") {
                            showDateRangePicker = false
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Сақтау") {
                            saveSelection()
                        }
                        .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .frame(width: 350)
            .presentationCompactAdaptation(.popover)
        }
    }
    
    // MARK: - Helpers
    
    private var datesBinding: Binding<Set<DateComponents>> {
        Binding {
            dates
        } set: { newValue in
            if newValue.isEmpty {
                dates = newValue
            } else if newValue.count > dates.count {
                if newValue.count == 1 {
                    dates = newValue
                } else if newValue.count == 2 {
                    dates = filledRange(selectedDates: newValue)
                } else if let firstMissingDate = newValue.subtracting(dates).first {
                    dates = [firstMissingDate]
                } else {
                    dates = []
                }
            } else if let firstMissingDate = dates.subtracting(newValue).first {
                dates = [firstMissingDate]
            } else {
                dates = []
            }
        }
    }
    
    private func preloadDates(with start: Date, end: Date) {
        let baseSet: Set<DateComponents> = [
            Calendar.current.dateComponents(datePickerComponents, from: start),
            Calendar.current.dateComponents(datePickerComponents, from: end)
        ]
        dates = filledRange(selectedDates: baseSet)
    }

    private func saveSelection() {
        let sortedDates = dates.compactMap { Calendar.current.date(from: $0) }.sorted()
        if let start = sortedDates.first, let end = sortedDates.last {
            currentDateRange = SleepStatsDateRange(start: start, end: end)
        }
        showDateRangePicker = false
    }
}

fileprivate let datePickerComponents: Set<Calendar.Component> = [
    .calendar, .era, .year, .month, .day
]

fileprivate func filledRange(selectedDates: Set<DateComponents>) -> Set<DateComponents> {
    let allDates = selectedDates.compactMap { Calendar.current.date(from: $0) }
    let sortedDates = allDates.sorted()
    var datesToAdd = [DateComponents]()
    if let first = sortedDates.first, let last = sortedDates.last {
        var date = first
        while date < last {
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) {
                if !sortedDates.contains(nextDate) {
                    let dateComponents = Calendar.current.dateComponents(datePickerComponents, from: nextDate)
                    datesToAdd.append(dateComponents)
                }
                date = nextDate
            } else {
                break
            }
        }
    }
    return selectedDates.union(datesToAdd)
}

