//
//  ChartView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 10.09.2025.
//

import SwiftUI
import Charts

struct ChartView<X: Hashable & Plottable>: View {
    let data: ChartData<X>
    let config: ChartConfig<X>
    @State private var selectedX: X?
    @State private var dragLocation: CGPoint?

    var body: some View {
        Chart {
            if config.showAverage, let avg = data.avgY {
                RuleMark(y: .value("Average", avg))
                    .lineStyle(StrokeStyle(lineWidth: 1, lineCap: .round, dash: [2]))
                    .foregroundStyle(Color.primaryOceanBlue)
            }
            if config.showAverage, let avg = data.avgYStart {
                RuleMark(y: .value("Average", avg))
                    .lineStyle(StrokeStyle(lineWidth: 1, lineCap: .round, dash: [2]))
                    .foregroundStyle(Color.primaryOceanBlue)
            }
            if let avgYStart = data.avgYStart,
                let avgY = data.avgY,
               let first = data.points.first?.x,
               let last = data.points.last?.x {
                RectangleMark(
                    xStart: .value("xStart", first),
                    xEnd: .value("xEnd", last),
                    yStart: .value("avgYStart", avgYStart),
                    yEnd: .value("avgY", avgY)
                )
                .foregroundStyle(Color.primaryOceanBlue.opacity(0.2))
            }

            // Draw chart points
            ForEach(Array(data.points.enumerated()), id: \.offset) { offset, point in
                let xLabelValue = config.xAxis.labelValue?(point.x) ?? .value(config.xAxis.label ?? "X", point.x)
                
                
                if let y = point.y {
                    let yLabelValue = config.yAxis.labelValue?(y) ?? .value(config.yAxis.label ?? "Y", y)
                    switch data.type {
                    case .bar:
                        if let start = point.yStart {
                            BarMark(
                                x: xLabelValue,
                                yStart: config.yAxis.labelValue?(start) ?? .value("Start", start),
                                yEnd: yLabelValue
                            )
                            .foregroundStyle(color(for: point))
                            .cornerRadius(3)
                            .opacity(isHighlighted(point) ? 1 : 0.2)
                        } else {
                            BarMark(
                                x: xLabelValue,
                                y: yLabelValue
                            )
                            .foregroundStyle(color(for: point))
                            .cornerRadius(3)
                            .opacity(isHighlighted(point) ? 1 : 0.2)
                        }
                    case .line:
                            LineMark(
                                x: xLabelValue,
                                y: yLabelValue
                            )
                            .opacity(isHighlighted(point) ? 1 : 0.2)
                            .foregroundStyle(Color.accentMediumSkyBlue)
                            AreaMark(
                                x: xLabelValue,
                                yStart: yLabelValue,
                                yEnd: .value("Baseline", data.minY ?? 0)
                            )
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [Color.primaryOceanBlue.opacity(0.5),
                                             Color.primaryOceanBlue.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(isHighlighted(point) ? 1 : 0.2)
                            PointMark(
                                x: xLabelValue,
                                y: yLabelValue
                            )
                            .symbol {
                                ZStack {
                                    Circle()
                                        .fill(isHighlighted(point) ? Color.white : Color.textLightGray) // inner fill
                                        .frame(width: isHighlighted(point) ? 5 : 3, height: isHighlighted(point) ? 5 : 3)
                                    if isHighlighted(point) {
                                        Circle()
                                            .stroke(Color.primaryOceanBlue, lineWidth: 2)
                                            .frame(width: 5, height: 5)
                                    }
                                }
                            }
                            .opacity(isHighlighted(point) ? 1 : 0.2)
                    }
                }
            }
        }
        .frame(height: 130)
        .modify({ chart in
            if let min = data.minY, let max = data.maxY, let marks = config.yAxis.labelScale?(min, max) {
                chart.chartYScale(domain: (marks.first ?? min)...(marks.last ?? max))
            }
        })
        .chartXAxis {
            if let values = config.xAxis.values {
                AxisMarks(values: values) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let xVal = value.as(X.self) {
                            Text(config.xAxis.format(xVal))
                        }
                    }
                }
            } else {
                AxisMarks { value in
                    AxisGridLine()
                    if let xVal = value.as(X.self) {
                        AxisValueLabel { Text(config.xAxis.format(xVal)) }
                    }
                }
            }
        }
        .chartYAxis {
            if let values = config.yAxis.values {
                AxisMarks(position: .leading, values: values) { value in
                    AxisValueLabel {
                        if let yVal = value.as(Int.self) {
                            Text(config.yAxis.format(yVal))
                        }
                    }
                }
            } else {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let yVal = value.as(Int.self) {
                            Text(config.yAxis.format(yVal))
                        }
                    }
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                LongPressDragGestureOverlay(location: $dragLocation)
                    .onChange(of: dragLocation) { location in
                        guard let location else {
                            selectedX = nil
                            return
                        }
                        let relativeX = location.x - geo[proxy.plotAreaFrame].origin.x
                        if let xValue: X = proxy.value(atX: relativeX) {
                            selectedX = data.points.first {
                                config.selectionConfig.isSameX(xValue, $0.x)
                            }?.x
                        }
                    }
                
                if let selectedX,
                   let item = data.points.first(where: { $0.x == selectedX }),
                   let xPos = proxy.position(forX: selectedX),
                   let yPos = proxy.position(forY: item.y ?? 0) {

                    let barWidth = proxy.plotAreaSize.width / CGFloat(data.points.count)
                    let centeredX = xPos + barWidth / 2

                    HStack(spacing: 4) {
                        Text(config.xAxis.format(selectedX))
                            .font(.caption2.weight(.regular))
                            .opacity(0.7)
                        if let score = item.y {
                            Text(config.yAxis.format(score))
                                .font(.caption.weight(.bold))
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

    // Helpers
    private func isHighlighted(_ point: ChartPoint<X>) -> Bool {
        selectedX == nil || selectedX == point.x
    }

    private func color(for point: ChartPoint<X>) -> Color {
        if let y = point.y {
            if y == data.maxY { return .accentBrightViolet }
            if y == data.minY { return .accentMediumSkyBlue }
        }
        return .accentSkyIceBlue
    }
}
