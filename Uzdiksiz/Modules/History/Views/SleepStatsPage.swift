//
//  SleepStatsPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 27.08.2025.
//

import SwiftUI

struct SleepStatsPage: View {
    @State private var currentDate: Date
    @ObservedObject var viewModel: SleepLogViewModel
    
    private var currentReport: SleepReport? {
        let currentKey = currentDate.dateKey
        return viewModel.sleepReports.value?.first { report in
            report.dateKey == currentKey
        }
    }

    init(viewModel: SleepLogViewModel) {
        self.viewModel = viewModel
        self._currentDate = .init(initialValue: Date())
    }

    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "kk_KZ")
        f.dateFormat = "EEE, d MMM"
        return f
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 0) {
                Text(formatter.string(from: currentDate).capitalized)
                Spacer()
                Image(systemName: "chart.bar.xaxis")
            }
            .font(.title3.weight(.bold))
            .foregroundColor(.textLightGray)
            .padding(.horizontal, 24)
            WeekdayPicker(selectedDate: $currentDate)
            InfinitePageView(
                selection: $currentDate,
                before: { date in
                    Calendar.current.date(byAdding: .weekOfYear, value: -1, to: date) ?? date
                },
                after: { date in
                    Calendar.current.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
                },
                view: { date in
                    pageContent(for: date)
                })
            .frame(maxHeight: .infinity)
        }
        .padding(.top, 16)
        .padding(.bottom, 32)
        .backgroundGradient(ignoring: [.top, .horizontal])
        .navigationBarHidden(true)
    }
    
    func pageContent(for date: Date) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            let report = report(for: date)
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 10) {
                    qualityBar(for: report)
                    sleepInfo(for: report)
                }
                .padding(.vertical, 16)
                CardRow(systemIcon: "text.bubble.fill", title: "Ұйқы жазбасы", content: {
                    Text("Бүгін той болып қалды, содан кеш ұйықтап қалдым")
                        .font(.caption)
                        .foregroundColor(.textSoftWhite)
                        .multilineTextAlignment(.leading)
                }) {
                    print("Tapped")
                }
                CardRow(systemIcon: "face.smiling", title: "Оянған күй", content: {
                    HStack(spacing: 16) {
                        moodButton(imageName: "happy_mood")
                        moodButton(imageName: "neutral_mood")
                        moodButton(imageName: "sad_mood")
                    }
                }) {
                    print("Tapped")
                }
            }
            .padding(.horizontal, 24)
            .opacity(report == nil ? 0.5 : 1)
        }
    }
    
    func moodButton(imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .foregroundColor(.textSoftWhite)
            .frame(width: 24, height: 24)
            .padding(10)
            .background(
                Circle().fill(.white.opacity(0.1))
            )
            .contentShape(Rectangle())
            .onTapGesture {
                print("tapped")
            }
    }
    
    @ViewBuilder
    func qualityBar(for report: SleepReport?) -> some View {
        let quality = report?.quality(targetStart: AppState.shared.sleepTime, targetEnd: AppState.shared.wakeTime)
        
        VStack(spacing: 0) {
            if let quality {
                Text("\(quality)")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundColor(.textSoftWhite)
            } else {
                Text("?")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundColor(.textSoftWhite)
            }
            Text("Cапа")
                .font(.caption)
                .foregroundColor(.textLightGray)
        }
        .frame(width: 100, height: 100)
        .background {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 8)
            Circle()
                .trim(from: 0, to: CGFloat(quality ?? 0)/100)
                .stroke(
                    LinearGradient(
                        colors: [.accentSkyIceBlue, .primaryOceanBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // start from top
        }
        .padding(10)
        .background {
            Circle()
                .fill(Color.white.opacity(0.05))
        }
    }
    
    func sleepInfo(for report: SleepReport?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ұйқы ұзақтығы")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.textLightGray)
                Group {
                    if let totalSleep = report?.totalSleepHM {
                        let (hours, minutes) = totalSleep
                        Text("\(hours)").font(.title3.weight(.bold)) + Text("сағ").font(.caption.weight(.bold)) +
                        Text("\(minutes)").font(.title3.weight(.bold)) + Text("мин").font(.caption.weight(.bold))
                    } else {
                        Text("Тіркелмеген").font(.title3.weight(.bold))
                    }
                }
                .foregroundColor(.textSoftWhite)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Ұйқы уақыты")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.textLightGray)
                if let intervalStrings = report?.intervalStrings {
                    ForEach(Array(intervalStrings.enumerated()), id: \.offset) { index, text in
                        Text(text)
                            .font(index == 0 ? .title3.weight(.bold) : .caption.weight(.bold))
                            .foregroundColor(index == 0 ? .textSoftWhite : .textLightGray)
                    }
                } else {
                    Text("Тіркелмеген").font(.title3.weight(.bold))
                        .foregroundColor(.textSoftWhite)
                }
            }
        }
        .padding(.vertical, 8)
    }
    

    private func report(for date: Date) -> SleepReport? {
        let currentKey = date.dateKey
        return viewModel.sleepReports.value?.first { report in
            report.dateKey == currentKey
        }
    }
}
