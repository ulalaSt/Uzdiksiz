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

    var body: some View {
        Chart(data.values, id: \.date) { item in
            switch data.type {
            case .quality, .duration:
                BarMark(
                    x: .value("Күн", item.date, unit: .day),
                    y: .value("Value", item.score ?? 0)
                )
                .foregroundStyle(item.score == data.maxScore ? .purple : .cyan)
                .cornerRadius(4)
            case .startTime, .endTime:
                if let score = item.score {
                    LineMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Minutes", score)
                    )
                    PointMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Minutes", score)
                    )
                }
            case .startAndEnd:
                BarMark(
                    x: .value("Күн", item.date, unit: .day),
                    y: .value("Value", item.score ?? 0)
                )
            }
        }
        .frame(height: 130)
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
                // Axis in 2.5h steps (150min)
                let step = 150
                let maxY = ((data.maxScore + step - 1) / step) * step
                AxisMarks(values: Array(stride(from: 0, through: maxY, by: step))) { value in
                    AxisValueLabel {
                        if let minutes = value.as(Int.self) {
                            let hoursString = String(format: "%.1fс.", Double(minutes) / 60.0)
                            Text(hoursString)
                        }
                    }
                }
            case .startTime, .endTime:
                let step = (data.maxScore - data.minScore) / 4
                AxisMarks(values: Array(stride(from: data.minScore, through: data.maxScore, by: step))) { value in
                    AxisValueLabel {
                        if let minutes = value.as(Int.self) {
                            let timeString = String(format: "%02d:%02d", minutes / 60, minutes % 60)
                            Text(timeString)
                        }
                    }
                }
            default:
                AxisMarks()
            }
        }
    }
    
    private func datesBetween(start: Date, end: Date) -> [Date] {
        var dates: [Date] = []
        var date = start
        let cal = Calendar.current
        while date <= end {
            dates.append(date)
            guard let next = cal.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }
        return dates
    }
}

private var dayLabelFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = .current
    f.setLocalizedDateFormatFromTemplate("d") // show day number; adjust template for "EEE d" etc.
    return f
}()
