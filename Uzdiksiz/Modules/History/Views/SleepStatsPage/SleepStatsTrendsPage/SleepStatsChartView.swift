//
//  SleepStatsChartView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 09.09.2025.
//
import Charts
import SwiftUI

struct SleepStatsChartView: View {
    let data: SleepStatsChartData
    private var axisDates: [Date] {
        datesBetween(start:  data.start, end: data.end)
    }
    @State private var selectedDate: Date?
    @State private var dragLocation: CGPoint?

    var body: some View {
        Chart {
            RuleMark(
                y: .value("Average", data.avgScore)
            )
            .lineStyle(StrokeStyle(lineWidth: 1, lineCap: .round, dash: [2]))
            .foregroundStyle(Color.primaryOceanBlue)
            let baseline = (data.type == .startTime || data.type == .endTime) ? makeTimeAxisMarks(min: data.minScore, max: data.maxScore).first ?? 0 : 0
            ForEach(data.values, id: \.date) { item in
                switch data.type {
                case .quality, .duration:
                    if let score = item.score {
                        BarMark(
                            x: .value("Күн", item.date, unit: .day),
                            y: .value("Value", score)
                        )
                        .foregroundStyle(item.score == data.maxScore ? Color.accentBrightViolet : item.score == data.minScore ? .accentMediumSkyBlue : .accentSkyIceBlue)
                        .cornerRadius(3)
                        .opacity(selectedDate == item.date || selectedDate == nil ? 1 : 0.2)
                    }
                case .startTime, .endTime:
                    if let score = item.score {
                        LineMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Minutes", score)
                        )
                        .opacity(selectedDate == nil ? 1 : 0.2)
                        .foregroundStyle(Color.accentMediumSkyBlue)
                        AreaMark(
                            x: .value("Day", item.date, unit: .day),
                            yStart: .value("Minutes", score),
                            yEnd: .value("Minutes", baseline))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Color.primaryOceanBlue.opacity(0.5), Color.primaryOceanBlue.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(selectedDate == nil ? 1 : 0.2)
                        PointMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Minutes", score)
                        )
                        .symbol {
                            ZStack {
                                let isHighlighted = selectedDate == nil || selectedDate == item.date
                                Circle()
                                    .fill(isHighlighted ? Color.white : Color.textLightGray) // inner fill
                                    .frame(width: isHighlighted ? 5 : 3, height: isHighlighted ? 5 : 3)
                                if isHighlighted {
                                    Circle()
                                        .stroke(Color.primaryOceanBlue, lineWidth: 2)
                                        .frame(width: 5, height: 5)
                                }
                            }
                        }
                        .opacity(selectedDate == item.date || selectedDate == nil ? 1 : 0.2)
                    }
                case .startAndEnd:
                    BarMark(
                        x: .value("Күн", item.date, unit: .day),
                        y: .value("Value", item.score ?? 0)
                    )
                }
            }
        }
        .frame(height: 130)
        .if(data.type == .startTime || data.type == .endTime, transform: { chart in
            chart.chartYScale(domain: {
                let marks = makeTimeAxisMarks(min: data.minScore, max: data.maxScore)
                return (marks.first ?? data.minScore)...(marks.last ?? data.maxScore)
            }())
        })
        .chartXAxis {
            AxisMarks(values: axisDates) { value in
                AxisGridLine()
                AxisValueLabel() {
                    if let date = value.as(Date.self) {
                        Text(dayLabelFormatter.string(from: date))
                    }
                }
            }
        }
        .chartYAxis {
            switch data.type {
            case .duration:
                let step = 150
                let maxY = ((data.maxScore + step - 1) / step) * step
                AxisMarks(position: .leading, values: Array(stride(from: 0, through: maxY, by: step))) { value in
                    AxisValueLabel {
                        if let minutes = value.as(Int.self) {
                            let hoursString = String(format: "%.1fс.", Double(minutes) / 60.0)
                            Text(hoursString)
                        }
                    }
                }
            case .startTime, .endTime:
                AxisMarks(position: .leading,
                          values: makeTimeAxisMarks(min: data.minScore, max: data.maxScore)) { value in
                    AxisValueLabel {
                        if let minutes = value.as(Int.self) {
                            Text(formatMinutesAsTime(minutes))
                        }
                    }
                }
            default:
                AxisMarks(position: .leading)
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                LongPressDragGestureOverlay(location: $dragLocation)
                    .onChange(of: dragLocation) { location in
                        guard let location else {
                            selectedDate = nil
                            return
                        }
                        let relativeX = location.x - geo[proxy.plotAreaFrame].origin.x
                        if let date: Date = proxy.value(atX: relativeX) {
                            selectedDate = data.values.first {
                                Calendar.current.isDate(date, inSameDayAs: $0.date)
                            }?.date
                        }
                    }
                
                if let selectedDate,
                   let item = data.values.first(where: { $0.date == selectedDate }),
                   let xPos = proxy.position(forX: selectedDate),
                   let yPos = proxy.position(forY: item.score ?? 0) {

                    let barWidth = proxy.plotAreaSize.width / CGFloat(data.values.count)
                    let centeredX = xPos + barWidth / 2

                    HStack(spacing: 4) {
                        Text(dayLabelFormatter.string(from: selectedDate))
                            .font(.caption2.weight(.regular))
                            .opacity(0.7)
                        if let score = item.score {
                            data.scoreText(score, font: .caption.weight(.bold), unitFont: .caption.weight(.bold))
                        }
                    }
                    .foregroundColor(.textSoftWhite)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 4)
                    .background(Color.primaryOceanBlue.opacity(0.7))
                    .cornerRadius(6)
                    .position(
                        x: centeredX + geo[proxy.plotAreaFrame].origin.x,
                        y: geo[proxy.plotAreaFrame].origin.y - 20
                    )
                    Path { path in
                        let startY = yPos + geo[proxy.plotAreaFrame].origin.y - 4
                        let endY = geo[proxy.plotAreaFrame].origin.y - 16

                        path.move(to: CGPoint(x: centeredX + geo[proxy.plotAreaFrame].origin.x, y: startY))
                        path.addLine(to: CGPoint(x: centeredX + geo[proxy.plotAreaFrame].origin.x, y: endY))
                    }
                    .stroke(
                        Color.primaryOceanBlue,
                        style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [2, 2])
                    )
                }
                
            }
        }
    }
    
    private func makeTimeAxisMarks(min minVal: Int, max maxVal: Int) -> [Int] {
        let step = Int(ceil(Double(maxVal - minVal) / 90.0) * 30)
        let mid = (minVal + maxVal) / 2
        let center = Int((Double(mid) / Double(step)).rounded()) * step
        return (-2...2).map { center + $0 * step }
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

    private func normalizeMinutes(_ minutes: Int) -> Int {
        var m = minutes % (24 * 60) // wrap within 24h
        if m < 0 { m += 24 * 60 }
        return m
    }

    private func formatMinutesAsTime(_ minutes: Int) -> String {
        let m = normalizeMinutes(minutes)
        let h = m / 60
        let min = m % 60
        return String(format: "%02d:%02d", h, min)
    }

    var dayLabelFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "kk_KZ")
        f.setLocalizedDateFormatFromTemplate("dd.MM")
        return f
    }()
}

