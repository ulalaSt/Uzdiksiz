//
//  SleepStatsChartSectionView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 09.09.2025.
//
import SwiftUI
import Charts

struct SleepStatsChartSectionView: View {
    let type: SleepStatsChartType
    let start: Date
    let end: Date
    private let reports: [SleepReport]
    init(start: Date, end: Date, reports: [SleepReport], type: SleepStatsChartType) {
        self.reports = reports
        self.start = start
        self.end = end
        self.type = type
    }
        
    private var title: String {
        switch type {
        case .quality: "Ұйқы сапасы"
        case .duration: "Ұйқы ұзақтығы"
        case .startTime: "Ұйқыға кету уақыты"
        case .endTime: "Ояну уақыты"
        case .startAndEnd: "Ұйқы уақыттары"
        }
    }
    
    var chartType: ChartType {
        switch type {
        case .quality, .startAndEnd, .duration:
            return .bar
        case .startTime, .endTime:
            return .line
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.callout.weight(.bold))
                    .foregroundColor(.textSoftWhite)
                    .padding(8)
                Spacer()
//                Text("Толығырақ")
//                    .font(.caption.weight(.semibold))
//                    .foregroundColor(Color.primaryOceanBlue)
//                    .padding(8)
            }
            VStack(alignment: .leading, spacing: 32) {
                legend
                ChartView(
                    data: .init(type: chartType,
                                points: values(for: type), avgY: type == .startAndEnd ? avgScore(for: .endTime) : nil, avgYStart: type == .startAndEnd ? avgScore(for: .startTime) : nil),
                    config: .init(
                        xAxis: .init(
                            label: title,
                            values: datesBetween(start:  start, end: end),
                            format: dayLabelFormatter.string,
                            labelScale: nil,
                            labelValue: { .value(title, $0, unit: .day) }),
                        yAxis: .init(
                            label: "Күні",
                            values: yValues,
                            format: { value in
                                switch type {
                                case .quality:
                                    "\(value)"
                                case .duration:
                                    String(format: "%.1fс.", Double(value) / 60.0)
                                case .startTime, .endTime:
                                    formatMinutesAsTime(value)
                                case .startAndEnd:
                                    formatMinutesAsTime(value)
                                }
                            },
                            labelScale: type == .startTime || type == .endTime ? makeTimeAxisMarks : nil),
                        selectionConfig: .init(isSameX: { date1, date2 in
                            Calendar.current.isDate(date1, inSameDayAs: date2)
                        })))
            }
            .padding(16)
            .glassBackground()
        }
    }
    
    private var yValues: [Int] {
        switch type {
        case .quality:
            return Array(stride(from: 0, through: 100, by: 20))
        case .duration:
            let step = 150
            let maxY = ((maxScore + step - 1) / step) * step
            return Array(stride(from: 0, through: maxY, by: step))
        case .startTime, .endTime:
            return makeTimeAxisMarks(min: minScore, max: maxScore)
        case .startAndEnd:
            return makeTimeAxisMarks(min: minScore, max: maxScore)
        }
    }
    var values: [ChartPoint<Date>] {
        values(for: type)
    }
    
    var maxScore: Int {
        switch type {
        case .quality, .duration, .startTime, .endTime:
            values.compactMap(\.y).max() ?? 0
        case .startAndEnd:
            values.compactMap(\.y).max() ?? 0
        }
    }
    
    var minScore: Int {
        switch type {
        case .quality, .duration, .startTime, .endTime:
            values.compactMap(\.yStart).min() ?? 0
        case .startAndEnd:
            values.compactMap(\.yStart).min() ?? 0
        }
    }
    
    var avgScore: Int { avgScore(for: type) }
    
    func avgScore(for type: SleepStatsChartType) -> (Int) {
        let scores = values(for: type).compactMap(\.y)
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / scores.count
    }
    

    // MARK: Legend
    private var legend: some View {
        HStack(spacing: 0) {
            if type != .startAndEnd {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 2) {
                            Circle()
                                .fill(Color.accentBrightViolet)
                                .frame(width: 12, height: 12)
                            Text("Ең жоғары")
                                .font(.caption.weight(.regular))
                                .foregroundColor(Color.textLightGray)
                        }
                        HStack(spacing: 2) {
                            Circle()
                                .fill(Color.accentMediumSkyBlue)
                                .frame(width: 12, height: 12)
                            Text("Ең төмен")
                                .font(.caption.weight(.regular))
                                .foregroundColor(Color.textLightGray)
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        maxScoreText(font: .caption.weight(.bold))
                            .foregroundColor(Color.textSoftWhite)
                        minScoreText(font: .caption.weight(.bold))
                            .foregroundColor(Color.textSoftWhite)
                    }
                }
            }
            Spacer()
            HStack(alignment: .bottom, spacing: 4) {
                Text("орт.")
                    .font(.caption)
                    .foregroundColor(Color.textLightGray)
                    .background(
                        GeometryReader { geo in
                            Path { path in
                                path.move(to: .zero)
                                path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                            }
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                            .foregroundColor(.primaryOceanBlue)
                        }
                    )
                avgScoreText(font: .title.weight(.bold), unitFont: .caption.weight(.bold))
                    .foregroundColor(Color.textSoftWhite)
            }
        }
    }
    
    private func makeTimeAxisMarks(min minVal: Int, max maxVal: Int) -> [Int] {
        let step = max(5, Int(ceil(Double(maxVal - minVal) / 90.0) * 30))
        let mid = (minVal + maxVal) / 2
        let center = Int((Double(mid) / Double(step)).rounded()) * step
        return (-2...2).map { center + $0 * step }
    }

    func values(for type: SleepStatsChartType) -> [ChartPoint<Date>] {
        if let days = Calendar.current.dateComponents([.day], from: start, to: end).day {
            let reportByDate = Dictionary(uniqueKeysWithValues: reports.map {
                (Calendar.current.startOfDay(for: $0.date), $0)
            })
            return (0...days).flatMap { offset -> [ChartPoint<Date>] in
                guard var day = Calendar.current.date(byAdding: .day, value: offset, to: start) else {
                    return []
                }
                day = Calendar.current.startOfDay(for: day)
                if let report = reportByDate[day] {
                    return values(for: type, day: day, report: report)
                } else {
                    return [.init(x: day, y: nil, yStart: nil)]
                }
            }
        } else {
            return []
        }
    }
    
    func values(for type: SleepStatsChartType, day: Date, report: SleepReport) -> [ChartPoint<Date>] {
        switch type {
        case .quality:
            return [.init(x: day, y: report.quality(), yStart: nil)]
        case .duration:
            return [.init(x: day, y: report.totalSleepMinutes, yStart: nil)]
        case .startTime:
            if let first = report.intervals.min(by: { $0.end.totalMinutes < $1.end.totalMinutes }) {
                var startMinutes = first.start.totalMinutes
                if let last = report.intervals.max(by: { $0.end.totalMinutes < $1.end.totalMinutes }) {
                    let endMinutes = last.end.totalMinutes
                    if startMinutes > endMinutes {
                        startMinutes -= 24 * 60
                    }
                }
                return [.init(x: day, y: startMinutes, yStart: nil)]
            }
            return [.init(x: day, y: nil, yStart: nil)]
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
                        return [.init(x: day, y: currentEnd, yStart: nil)]
                    }
                } else {
                    return [.init(x: day, y: interval.end.totalMinutes, yStart: nil)]
                }
            }
            return [.init(x: day, y: nil, yStart: nil)]
        case .startAndEnd:
            if report.intervals.isEmpty {
                return [.init(x: day, y: nil, yStart: nil)]
            } else {
                return report.intervals.map { start, end in
                    var startMinutes = start.totalMinutes
                    let endMinutes = end.totalMinutes
                    if startMinutes > endMinutes {
                        startMinutes -= 24 * 60
                    }
                    return .init(x: day, y: endMinutes, yStart: startMinutes)
                }
            }
        }
    }
    
    func maxScoreText(font: Font, unitFont: Font? = nil) -> some View {
        scoreText(maxScore, font: font, unitFont: unitFont)
    }
    
    func minScoreText(font: Font, unitFont: Font? = nil) -> some View {
        scoreText(minScore, font: font, unitFont: unitFont)
    }
    
    func avgScoreText(font: Font, unitFont: Font? = nil) -> some View {
        scoreText(avgScore, font: font, unitFont: unitFont)
    }
    
    func scoreText(_ value: Int, font: Font, unitFont: Font? = nil) -> some View {
        switch type {
        case .quality:
            Text("\(value)")
                .font(font)
        case .duration:
            Text("\(value / 60)").font(font) + Text("сағ").font(unitFont ?? font) +
            Text(" \(value % 60)").font(font) + Text("мин").font(unitFont ?? font)
        case .startTime, .endTime:
            Text(formatMinutesAsTime(value))
                .font(font)
        case .startAndEnd:
            Text("\(formatMinutesAsTime(avgScore(for: .startTime)) + "-" + formatMinutesAsTime(avgScore(for: .endTime)))").font(font)
        }
    }
    
    private func normalizeMinutes(_ minutes: Int) -> Int {
        var m = minutes % (24 * 60)
        if m < 0 { m += 24 * 60 }
        return m
    }

    private func formatMinutesAsTime(_ minutes: Int) -> String {
        let m = normalizeMinutes(minutes)
        let h = m / 60
        let min = m % 60
        return String(format: "%02d:%02d", h, min)
    }

    private func datesBetween(start: Date, end: Date) -> [Date] {
        let cal = Calendar.current
        guard start <= end else { return [] }
        
        guard let totalDays = cal.dateComponents([.day], from: start, to: end).day else {
            return []
        }
        
        let step = max(1, totalDays / 6)

        var dates: [Date] = []
        var current = start
        while current < end {
            dates.append(cal.startOfDay(for: current))
            guard let next = cal.date(byAdding: .day, value: step, to: current) else { break }
            current = next
        }
        dates.append(cal.startOfDay(for: end))

        return dates
    }
    
    var dayLabelFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "kk_KZ")
        f.setLocalizedDateFormatFromTemplate("dd.MM")
        return f
    }()
}
