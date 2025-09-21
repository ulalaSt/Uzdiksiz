//
//  SleepStatsDailyPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 27.08.2025.
//

import SwiftUI
import Foundation

struct SleepStatsDailyPage: View {
    @State private var currentDate: Date
    @State private var deletionState: Loadable<Void> = .notRequested
    @ObservedObject var viewModel: SleepReportViewModel
    @EnvironmentObject var appState: AppState
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
        .backgroundGradient(ignoring: .all)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    func pageContent(for date: Date) -> some View {
        VStack(spacing: 10) {
            ScrollView(.vertical, showsIndicators: false) {
                let report = report(for: date)
                let sessions = viewModel.sleepSessions.value?.filter({
                    $0.report?.id == report?.id
                })
                VStack(alignment: .leading, spacing: 16) {
                    let streak = streakEndingOn(date: date)
                    HStack(alignment: .center, spacing: 0) {
                        HStack(spacing: 3) {
                            if streak > 1 {
                                Image("lightning")
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 16, height: 19)
                            }
                            Text("Ұйқы сапасы")
                                .font(.title3.weight(.bold))
                        }
                        Spacer()
                        if streak > 1 {
                            Text("\(streak) күн қатар")
                                .font(.footnote.weight(.medium))
                        }
                    }
                    .modify({ view in
                        if streak > 1 {
                            view
                                .foregroundStyle(LinearGradient(colors: [.softSkyBlue,.softPurple, .vividMagenta], startPoint: .bottomLeading, endPoint: .topTrailing)
                                )
                        } else {
                            view
                                .foregroundStyle(Color.textLightGray)
                        }
                    })
                    .padding(.horizontal, 8)
                    HStack(alignment: .top, spacing: 10) {
                        qualityBar(for: report)
                        sleepInfo(for: report, sessions: sessions, date: date)
                    }
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if let sessions {
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
                                    .frame(width: 24, height: 24)
                                    .modify({ view in
                                        if #available(iOS 26, *), appState.isGlassEffectEnabled {
                                            view.glassEffect(in: .circle)
                                        }
                                    })
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(Color.textSoftWhite)
                                    .contentShape(.rect)
                            }
                        }
                        .padding(.horizontal, 8)
                        let isFullQuality = report?.quality() == 100
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 12) {
                                if isFullQuality {
                                    SleepTimelineView(sessions: Array(sessions), mainSleepColor: fullQualityGradient)
                                } else {
                                    SleepTimelineView(sessions: Array(sessions), mainSleepColor: Color.primaryOceanBlue)
                                }
                                HStack(spacing: 10) {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .modify { rect in
                                                if isFullQuality {
                                                    rect.fill(fullQualityGradient)
                                                } else {
                                                    rect.fill(Color.primaryOceanBlue)
                                                }
                                            }
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
                            .glassBackground()
                            ForEach(Array(sessions)) { session in
                                let isNap = session.minutesDuration < 30
                                HStack(spacing: 8) {
                                    Circle().fill(isNap ? Color.accentSkyIceBlue : .primaryOceanBlue)
                                        .frame(width: 10, height: 10)
                                    Text(session.intervalString)
                                        .font(.title3.weight(.bold))
                                        .foregroundColor(Color.textSoftWhite)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .glassBackground()
                                .overlay(alignment: .trailing, content: {
                                    Menu {
                                        Button {
                                            viewModel.editSleepSessionTapped(session: session)
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
                                            .frame(width: 44, height: 44)
                                            .foregroundColor(.textLightGray)
                                    }
                                    .buttonStyle(.plain)
                                })
                            }
                        }
//                        journaling
                    }
                }
                .padding(.horizontal, 24)
                .opacity(report == nil ? 0.5 : 1)
            }
            if date <= Date(), report(for: date) == nil {
                DefaultButtonView(title: "+ Ұйқы қосу", state: .tertiary) {
                    onAddSleep(date)
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    @ViewBuilder
    var journaling: some View {
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
    
    var fullQualityGradient: LinearGradient {
        LinearGradient(colors: [.softSkyBlue,.softPurple, .vividMagenta], startPoint: .bottomLeading, endPoint: .topTrailing)
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
    
    private func streakEndingOn(date: Date) -> Int {
        guard let reports = viewModel.sleepReports.value else { return 0 }

        let calendar = Calendar.current

        let perfectDates = reports
            .filter { $0.quality() == 100 }
            .map { calendar.startOfDay(for: $0.date) }
            .sorted()

        let target = calendar.startOfDay(for: date)
        guard let endIndex = perfectDates.firstIndex(of: target) else { return 0 }

        var streak = 1
        if endIndex > 0 {
            for idx in stride(from: endIndex, through: 1, by: -1) {
                let current = perfectDates[idx]
                let previous = perfectDates[idx - 1]

                if let expectedPrev = calendar.date(byAdding: .day, value: -1, to: current),
                   calendar.isDate(previous, inSameDayAs: expectedPrev) {
                    streak += 1
                } else {
                    break
                }
            }
        }

        return streak
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
                        colors: quality == 100 ? [.softSkyBlue,.softPurple, .vividMagenta] : [.accentSkyIceBlue, .primaryOceanBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // start from top
        }
        .padding(10)
        .background {
            if #available(iOS 26, *), appState.isGlassEffectEnabled {
                Color.clear.glassEffect(.clear, in: .circle)
            } else {
                Circle()
                    .fill(Color.white.opacity(0.05))
            }
        }
    }
    
    func sleepInfo(for report: SleepReport?, sessions: [SleepSession]?, date: Date) -> some View {
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
                
                if let sessions, let main = sessions.max(by: {
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
