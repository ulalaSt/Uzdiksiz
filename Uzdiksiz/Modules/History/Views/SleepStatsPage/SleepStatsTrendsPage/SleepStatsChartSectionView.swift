//
//  SleepStatsChartSectionView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 09.09.2025.
//
import SwiftUI
import Charts

struct SleepStatsChartSectionView: View {
    private var data: SleepStatsChartData
    init(start: Date, end: Date, reports: [SleepReport], type: SleepStatsChartType) {
        self.data = .init(start: start, end: end, type: type, reports: reports)
    }
        
    private var title: String {
        switch data.type {
        case .quality: "Ұйқы сапасы"
        case .duration: "Ұйқы ұзақтығы"
        case .startTime: "Ұйқыға кету уақыты"
        case .endTime: "Ояну уақыты"
        case .startAndEnd: "Ұйқы уақыттары"
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
                Text("Толығырақ")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color.primaryOceanBlue)
                    .padding(8)
            }
            VStack(alignment: .leading, spacing: 32) {
                legend
                SleepStatsChartView(data: data)
            }
            .padding(16)
            .background(Color.backgroundDeepNavy)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    // MARK: Legend
    private var legend: some View {
        HStack(spacing: 0) {
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
                    data.scoreText(data.maxScore, font: .caption.weight(.bold))
                        .foregroundColor(Color.textSoftWhite)
                    data.scoreText(data.minScore, font: .caption.weight(.bold))
                        .foregroundColor(Color.textSoftWhite)
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
                data.scoreText(data.avgScore, font: .title.weight(.bold), unitFont: .caption.weight(.bold))
                    .foregroundColor(Color.textSoftWhite)
            }
        }
    }
}
