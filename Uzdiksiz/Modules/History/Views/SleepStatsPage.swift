//
//  SleepStatsPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 27.08.2025.
//

import SwiftUI

struct SleepStatsPage: View {
    @State private var currentDate: Date
    @State private var deletionState: Loadable<Void> = .notRequested
    @ObservedObject var viewModel: SleepReportViewModel
    var onShowGraph: () -> Void
    var onAddSleep: (Date) -> Void

    private var currentReport: SleepReport? {
        let currentKey = currentDate.dateKey
        return viewModel.sleepReports.value?.first { report in
            report.dateKey == currentKey
        }
    }

    init(viewModel: SleepReportViewModel, onShowGraph: @escaping () -> Void, onAddSleep: @escaping (Date) -> Void) {
        self.viewModel = viewModel
        self._currentDate = .init(initialValue: Date())
        self.onShowGraph = onShowGraph
        self.onAddSleep = onAddSleep
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
                CalendarPopoverButton(selectedDate: $currentDate) { date in
                    report(for: date)?.quality() ?? 0
                }
                Spacer()
                Button {
                    onShowGraph()
                } label: {
                    Image(systemName: "chart.bar.xaxis")
                }
            }
            .font(.title3.weight(.bold))
            .foregroundColor(.textLightGray)
            .padding(.horizontal, 24)
            WeekdayPicker(selectedDate: $currentDate, progressForDate: { date in
                report(for: date)?.quality() ?? 0
            })
            InfinitePageView(
                selection: $currentDate,
                before: { date in
                    Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
                },
                after: { date in
                    Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
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
        VStack(spacing: 10) {
            ScrollView(.vertical, showsIndicators: false) {
                let report = report(for: date)
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 10) {
                        qualityBar(for: report)
                        sleepInfo(for: report, date: date)
                    }
                    .padding(.vertical, 16)
                    if let sessions = report?.sessions as? Set<SleepSession> {
                        HStack(alignment: .center, spacing: 0) {
                            Text("Ұйқы тізбегі")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.textLightGray)
                            Spacer()
                            Button {
                                onAddSleep(date)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(Color.textSoftWhite)
                            }
                        }
                        .padding(.horizontal, 8)
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 12) {
                                SleepTimelineView(sessions: Array(sessions))
                                HStack(spacing: 10) {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(Color.primaryOceanBlue)
                                            .frame(width: 10, height: 10)
                                        Text("Негізгі ұйқы")
                                            .font(.caption)
                                            .foregroundColor(Color.textSoftWhite)
                                    }
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(Color.accentSkyIceBlue)
                                            .frame(width: 10, height: 10)
                                        Text("Қысқа ұйқы")
                                            .font(.caption)
                                            .foregroundColor(Color.textSoftWhite)
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.backgroundDeepNavy)
                            )
                            ForEach(Array(sessions)) { session in
                                let isNap = session.minutesDuration < 30
                                HStack(spacing: 8) {
                                    Circle().fill(isNap ? Color.accentSkyIceBlue : .primaryOceanBlue)
                                        .frame(width: 10, height: 10)
                                    Text(session.intervalString)
                                        .font(.title3.weight(.bold))
                                        .foregroundColor(Color.textSoftWhite)
                                    Spacer()
                                    Menu {
                                        Button {
                                            // edit action
                                        } label: {
                                            Label("Өңдеу", systemImage: "square.and.pencil")
                                        }

                                        Button(role: .destructive) {
                                            Task {
                                                await viewModel.deleteSession(sessionID: session.id, state: $deletionState)
                                            }
                                        } label: {
                                            Label("Жою", systemImage: "trash")
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.textLightGray)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.backgroundDeepNavy)
                                )

                            }
                        }
                    }
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
            if date <= Date(), report(for: date) == nil {
                Button {
                    onAddSleep(date)
                } label: {
                    DefaultButtonView(title: "+ Ұйқы қосу", state: .tertiary)
                }
                .padding(.horizontal, 24)
            }
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
        let quality = report?.quality()
        
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
    
    func sleepInfo(for report: SleepReport?, date: Date) -> some View {
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
                Text("Негізгі ұйқы")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.textLightGray)
                
                if let sessions = report?.sessions as? Set<SleepSession>,
                   let main = sessions.max(by: {
                       $0.minutesDuration < $1.minutesDuration
                   }) {
                    Text(main.intervalString)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.textSoftWhite)
                } else {
                    Text("Тіркелмеген")
                        .font(.title3.weight(.bold))
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
