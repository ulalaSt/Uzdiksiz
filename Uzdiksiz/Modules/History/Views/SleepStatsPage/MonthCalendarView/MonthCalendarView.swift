//
//  MonthCalendarView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 08.09.2025.
//

import SwiftUI

struct MonthCalendarView: View {
    @State private var displayMonth: Date
    @Binding private var selectedDate: Date

    // closure returns Int 0..100
    var progressForDate: (Date) -> Int
    var onSelectDate: (Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    init(progressForDate: @escaping (Date) -> Int,
         selectedDate: Binding<Date>,
         onSelectDate: @escaping (Date) -> Void) {
        // init displayMonth to the month of the selectedDate
        let initialMonth = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: selectedDate.wrappedValue)
        ) ?? Date()

        _displayMonth = State(initialValue: initialMonth)
        self.progressForDate = progressForDate
        self._selectedDate = selectedDate
        self.onSelectDate = onSelectDate
    }

    var body: some View {
        ZStack {
            Color.backgroundDeepNavy.scaleEffect(1.5)
            VStack(spacing: 8) {
                header
                HStack(spacing: 4) {
                    ForEach(["Дүй", "Сей", "Сәр", "Бей", "Жұм", "Сен", "Жек"], id: \.self) { day in
                        Text(day)
                            .font(.caption.weight(.bold))
                            .foregroundColor(.textSoftWhite)
                            .frame(maxWidth: 40)
                    }
                }
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(daysForMonth(), id: \.self) { date in
                        let inMonth = calendar.isDate(date, equalTo: displayMonth, toGranularity: .month)
                        DayCell(date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                isWithinDisplayedMonth: inMonth && (date < Date() || calendar.isDate(date, inSameDayAs: selectedDate)),
                                progress: Double(progressForDate(date)) / 100.0,
                                dayTapped: { onSelectDate($0) })
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .frame(maxWidth: 420)
    }

    // MARK: - Header
    var header: some View {
        HStack {
            Button(action: {
                displayMonth = calendar.date(byAdding: .month, value: -1, to: displayMonth) ?? displayMonth
            }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthTitle(for: displayMonth))
                .font(.headline)
            Spacer()
            Button(action: {
                displayMonth = calendar.date(byAdding: .month, value: 1, to: displayMonth) ?? displayMonth
            }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal, 6)
        .foregroundColor(.textLightGray)
    }

    // MARK: - Helpers
    private func monthTitle(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        fmt.locale = Locale(identifier: "kk_KZ")
        return fmt.string(from: date).capitalized
    }
    
    /// Returns an array of Dates covering the calendar grid for the month,
    /// including leading/trailing days to fill weeks.
    private func daysForMonth() -> [Date] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: displayMonth),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayMonth))
        else { return [] }

        // first day of month weekday index (1 = Sunday in Gregorian where calendar.firstWeekday could be different)
        let weekdayOfFirst = calendar.component(.weekday, from: monthStart)
        // The number of leading offset cells to display
        // Considering calendar.firstWeekday
        let firstWeekdayIndex = calendar.firstWeekday // 1..7
        var leading = weekdayOfFirst - firstWeekdayIndex
        if leading < 0 { leading += 7 }

        // start date to include
        guard let startDate = calendar.date(byAdding: .day, value: -leading, to: monthStart) else { return [] }

        // total cells: weeks * 7
        let daysCount = monthRange.count
        let totalCells = ((leading + daysCount + 6) / 7) * 7

        return (0..<totalCells).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startDate)
        }
    }
}
