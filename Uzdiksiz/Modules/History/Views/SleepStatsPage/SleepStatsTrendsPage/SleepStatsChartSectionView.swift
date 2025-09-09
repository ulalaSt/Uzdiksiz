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
            VStack(alignment: .leading, spacing: 24) {
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
                    scoreText(data.maxScore, font: .caption.weight(.bold))
                        .foregroundColor(Color.textSoftWhite)
                    scoreText(data.minScore, font: .caption.weight(.bold))
                        .foregroundColor(Color.textSoftWhite)
                }
            }
            Spacer()
            HStack(alignment: .bottom, spacing: 4) {
                Text("орт.")
                    .font(.caption)
                    .foregroundColor(Color.textLightGray)
                scoreText(data.avgScore, font: .title.weight(.bold), unitFont: .caption.weight(.bold))
                    .foregroundColor(Color.textSoftWhite)
            }
        }
    }
    
    private func scoreText(_ value: Int, font: Font, unitFont: Font? = nil) -> some View {
        switch data.type {
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
            Text("")
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
}
