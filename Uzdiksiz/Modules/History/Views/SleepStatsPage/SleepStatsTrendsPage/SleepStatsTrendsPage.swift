//
//  SleepStatsTrendsPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 08.09.2025.
//

import SwiftUI

struct SleepStatsTrendsPage: View {
    @Environment(\.dismiss) var dismiss
    @State var currentState: SleepStatsState = .weekly
    @State private var exportURL: URL?
    @State private var showingShareSheet: Bool = false
    @State var dateInterval: DateInterval
    @State var shift: Int = 0
    @Namespace var namespace
    let viewModel: SleepReportViewModel
    
    var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    
    func interval(for state: SleepStatsState) -> DateInterval {
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
    
    init(viewModel: SleepReportViewModel) {
        self.viewModel = viewModel
        self._dateInterval = .init(initialValue: Calendar.current.dateInterval(of: .weekOfYear, for: Date()) ?? .init())
    }

    var body: some View {
        VStack(spacing: 24) {
            selector
                .padding(.top, 12)
            TabView(selection: $currentState) {
                ForEach(SleepStatsState.allCases) { state in
                    VStack(spacing: 16) {
                        rangeNavigator(for: state)
                        if let reports = filteredReports(for: state) {
                            ScrollView(showsIndicators: false) {
                                SleepStatsTrendsListView(reports: reports, currentInterval: interval(for: state))
                            }
                        } else {
                            ProgressView("Жүктелуде…")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                    .tag(state)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .toolbar(.hidden, for: .tabBar)
        }
        .padding(.horizontal, 24)
        .navigationBarHidden(false)
        .colorScheme(.dark)
        .navigationBarBackButtonHidden()
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                Text("Статистика")
                    .foregroundColor(.textSoftWhite)
                    .font(.headline.weight(.semibold))
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body)
                        .frame(width: 44, height: 44)
                        .foregroundColor(.textSoftWhite)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let reports = filteredReports(for: currentState),
                        let url = exportReportsFile(reports) {
                        exportURL = url
                        showingShareSheet = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.body)
                        .frame(width: 44, height: 44)
                        .foregroundColor(.textSoftWhite)
                }
                .disabled(viewModel.sleepReports.value == nil)
            }
        })
        .backgroundGradient(ignoring: .all)
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportURL {
                ActivityView(activityItems: [url], applicationActivities: nil)
            }
        }
    }
    
    func filteredReports(for state: SleepStatsState) -> [SleepReport]? {
        let calendar = Calendar.current
        let currentInterval = interval(for: state)
        let actualLastDay = Calendar.current.date(byAdding: .day, value: -1, to: currentInterval.end) ?? currentInterval.end
        
        return viewModel.sleepReports.value?.filter { r in
            calendar.compare(r.date, to: currentInterval.start, toGranularity: .day) != .orderedAscending &&
            calendar.compare(r.date, to: actualLastDay, toGranularity: .day) != .orderedDescending
        }
    }
    
    var selector: some View {
        HStack(spacing: 0) {
            let states = Array(SleepStatsState.allCases.enumerated())
            ForEach(states, id: \.offset) { (index, state) in
                let isActive = currentState == state
                if !isActive, let prev = states.first(where: { $0.0 == index-1}), currentState != prev.1 {
                    Rectangle().fill(Color.white.opacity(0.1)).frame(width: 1, height: 16)
                }
                Text(state.title)
                    .font(isActive ? .caption2.weight(.semibold) : .caption2)
                    .foregroundColor(.textSoftWhite)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .background {
                        if isActive {
                            Capsule()
                                .fill(Color.primaryOceanBlue)
                                .matchedGeometryEffect(id: "selector", in: namespace)
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            currentState = state
                        }
                    }
            }
        }
        .background(Capsule().fill(.white.opacity(0.1)))
    }
    
    @ViewBuilder
    func rangeNavigator(for state: SleepStatsState) -> some View {
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
                Text(interval(for: state).start.formattedRange(to: interval(for: state).end))
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

    func exportReportsFile(_ reports: [SleepReport]) -> URL? {
        let csvString = exportReportsAsCSV(reports)
        
        let interval = interval(for: currentState)
        let startString = interval.start.formatted(date: .numeric, time: .omitted)
        let endString = Calendar.current.date(byAdding: .day, value: -1, to: interval.end)?
            .formatted(date: .numeric, time: .omitted) ?? interval.end.formatted(date: .numeric, time: .omitted)
        
        let fileName = "SR-\(startString)-\(endString).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("❌ Failed to write CSV:", error)
            return nil
        }
    }

    let iso8601DayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Only date part
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()

    func exportReportsAsCSV(_ reports: [SleepReport]) -> String {
        var csv = "Күн,Ұйқы ұзақтығы (минут),Ұйқы ұзақтығы (сағат:минут),Сапа,Ұйқы мақсаты,Ояну мақсаты,Сессиялар\n"

        for report in reports.sorted(by: { $0.date < $1.date }) {
            let dateString = iso8601DayFormatter.string(from: report.date)
            let totalMinutes = report.totalSleepMinutes
            let totalHM = "\(report.totalSleepHM.hours)cағ \(report.totalSleepHM.minutes)мин"
            let quality = report.quality()
            let targetStart = report.targetStart.toString()
            let targetEnd = report.targetEnd.toString()
            
            // Sessions as "HH:mm-HH:mm | HH:mm-HH:mm"
            let sessionsString = report.intervals
                .map { "\($0.start.toString())-\($0.end.toString())" }
                .joined(separator: " | ")
            
            let row = """
            \(dateString),\(totalMinutes),\(totalHM),\(quality),\(targetStart),\(targetEnd),"\(sessionsString)"
            """
            csv.append(row + "\n")
        }
        
        return csv
    }
}

enum SleepStatsState: Int, Equatable, CaseIterable, Identifiable, Hashable {
    var id: Self { self }
    case weekly
    case monthly
    case custom
    
    var title: String {
        switch self {
        case .weekly:
            "Апта"
        case .monthly:
            "Ай"
        case .custom:
            "Басқа"
        }
    }
}
