//
//  WeekdayPicker.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 27.08.2025.
//
import SwiftUI

struct WeekdayPicker: View {
    @Binding var selectedDate: Date
    
    private let calendar = Calendar.current
    private let today = Date()
    
    // Dynamic offsets
    @State private var currentOffset: Int = 0

    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "kk_KZ") // Kazakh
        f.dateFormat = "EEE"
        return f
    }()
    
    var body: some View {
        weekView(for: 0)
            .frame(maxWidth: .infinity)
            .hidden()
            .overlay {
                InfinitePageView(
                    selection: $currentOffset,
                    before: { $0 - 1 },
                    after: { $0 + 1},
                    view: { index in
                        weekView(for: index)
                    }
                )
            }
            .onChange(of: currentOffset) { newOffset in
                guard let startOfWeek = calendar.date(byAdding: .weekOfYear, value: newOffset, to: startOfCurrentWeek),
                      let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else { return }
                
                if calendar.isDate(today, inSameDayAs: startOfWeek) || (today > startOfWeek && today < endOfWeek) || calendar.isDate(today, inSameDayAs: endOfWeek) {
                    selectedDate = today
                } else {
                    selectedDate = endOfWeek
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear {
                // Initialize currentOffset based on selectedDate
                currentOffset = weeksBetween(startOfCurrentWeek, and: selectedDate)
            }
    }
    
    @ViewBuilder
    private func weekView(for weekOffset: Int) -> some View {
        let startOfWeek = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfCurrentWeek)!
        let dates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
        
        HStack(spacing: 10) {
            ForEach(dates, id: \.self) { date in
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                VStack(spacing: 4) {
                    Text(formatter.string(from: date).capitalized)
                        .font(.caption.weight(.medium))
                        .foregroundColor(isSelected ? Color.textSoftWhite : .textLightGray)
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color.accentMediumSkyBlue : Color.primaryOceanBlue, lineWidth: 3)
                        Text("\(calendar.component(.day, from: date))")
                            .foregroundColor(isSelected ? .accentMediumSkyBlue : .textLightGray)
                            .font(.caption.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    
                    if calendar.isDate(date, inSameDayAs: today) {
                        Circle()
                            .fill(Color.accentSkyIceBlue)
                            .frame(width: 5, height: 5)
                            .shadow(color: .white.opacity(0.5), radius: 4, x: 0, y: 0)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 5, height: 5)
                    }
                }
                .padding(4)
                .contentShape(Rectangle())
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accentMediumSkyBlue, lineWidth: 0.5)
                            .padding(0.25)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.1))
                    }
                }
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Helpers
    
    private var startOfCurrentWeek: Date {
        calendar.dateInterval(of: .weekOfYear, for: today)!.start
    }
    
    private func weeksBetween(_ from: Date, and to: Date) -> Int {
        calendar.dateComponents([.weekOfYear], from: from, to: to).weekOfYear ?? 0
    }
}

struct InfinitePageView<C, T>: View where C: View, T: Hashable {
    @Binding var selection: T

    let before: (T) -> T
    let after: (T) -> T

    @ViewBuilder let view: (T) -> C

    @State private var currentTab: Int = 0

    var body: some View {
        let previousIndex = before(selection)
        let nextIndex = after(selection)
        TabView(selection: $currentTab) {
            view(previousIndex)
                .tag(-1)

            view(selection)
                .onDisappear() {
                    if currentTab != 0 {
                        selection = currentTab < 0 ? previousIndex : nextIndex
                        currentTab = 0
                    }
                }
                .tag(0)

            view(nextIndex)
                .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .disabled(currentTab != 0) // FIXME: workaround to avoid glitch when swiping twice very quickly
    }
}
