//
//  SleepHistoryView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//
import SwiftUI

struct SleepHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SleepLogViewModel
    @State var sessionToDelete: SleepSession? = nil
    @State private var showAddLogSheet = false

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                if let expected = viewModel.expectedWakeTime.value, let expected {
                    Text("🎯 Мақсат: \(expected) ояну")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                if let logs = viewModel.sleepReports.value, !logs.isEmpty {
                    let avg = averageDuration(for: logs)
                    Text("📊 Орташа ұйқы ұзақтығы: \(avg.hour) сағ \(avg.minute) мин")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                
                if case let .loaded(reports) = viewModel.sleepReports {
                    if reports.isEmpty {
                        Text("💤 ӘЗІРГЕ ДЕРЕКТЕР ЖОҚ")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    } else {
                        // Sort reports by dateKey descending
                        let sortedReports = reports.sorted { $0.dateKey > $1.dateKey }

                        ForEach(sortedReports, id: \.id) { report in
                            VStack(alignment: .leading, spacing: 16) {
                                // Convert dateKey back to Date for display
                                if let date = viewModel.date(from: report.dateKey) {
                                    Text("📅 \(formatter.string(from: date)) — \(formatDuration([report]))")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.leading, 8)
                                }

                                if let sessions = report.sessions as? Set<SleepSession> {
                                    ForEach(Array(sessions).sorted { lhs, rhs in
                                        lhs.startHour * 60 + lhs.startMinute < rhs.startHour * 60 + rhs.startMinute
                                    }, id: \.id) { session in
                                        VStack(alignment: .leading, spacing: 8) {
                                            cell(for: session) // 🔹 Adapt your cell function to handle SleepSession
                                        }
                                    }
                                }
                            }
                        }

                        Button("CSV ретінде экспорттау") {
//                            viewModel.exportSleepReportsCSV(reports: reports)
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else {
                    Text("Жүктелуде...")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(16)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Ұйқы тарихы")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            if let wakeTime = viewModel.expectedWakeTime.value, let wakeTime {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddLogSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            if let wakeTime = viewModel.expectedWakeTime.value, let wakeTime {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SleepChartView(logs: viewModel.logs.value ?? [], targetWakeTime: wakeTime)
                    } label: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            
        }
//        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            if viewModel.logs == .notRequested {
                viewModel.fetchLogs()
            }
        }
        .sheet(isPresented: $showAddLogSheet) {
            AddSleepLogView { date, sleep, wake in
                viewModel.createSleepLog(date: date, sleepTime: sleep, wakeTime: wake)
                showAddLogSheet = false
            }
        }
    }
    
    var bgView: some View {
        Image("night_bg")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    func formatDuration(_ reportsForDate: [SleepReport]) -> String {
        var totalMinutes = 0
        
        for report in reportsForDate {
            if let sessions = report.sessions as? Set<SleepSession> {
                for session in sessions {
                    let start = Int(session.startHour) * 60 + Int(session.startMinute)
                    let end   = Int(session.endHour) * 60 + Int(session.endMinute)
                    
                    // Handle overnight sleep (e.g. 22:00 → 07:00)
                    let duration = end >= start ? (end - start) : ((24 * 60 - start) + end)
                    totalMinutes += duration
                }
            }
        }
        
        let hour = totalMinutes / 60
        let minute = totalMinutes % 60
        return "\(hour) сағ \(minute) мин"
    }
    
    func averageDuration(for reports: [SleepReport]) -> (hour: Int, minute: Int) {
        guard !reports.isEmpty else { return (0, 0) }
        
        var totalMinutesAll = 0
        
        for report in reports {
            if let sessions = report.sessions as? Set<SleepSession> {
                for session in sessions {
                    let start = Int(session.startHour) * 60 + Int(session.startMinute)
                    let end   = Int(session.endHour) * 60 + Int(session.endMinute)
                    
                    // handle overnight sleep (e.g. 22:00 → 07:00)
                    let duration = end >= start ? (end - start) : ((24 * 60 - start) + end)
                    
                    totalMinutesAll += duration
                }
            }
        }
        
        let uniqueDates = Set(reports.map { $0.dateKey })
        guard !uniqueDates.isEmpty else { return (0, 0) }
        
        let averageMinutes = totalMinutesAll / uniqueDates.count
        return (averageMinutes / 60, averageMinutes % 60)
    }

    func cell(for session: SleepSession) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("😴 Ұйқы ұзақтығы: \(viewModel.duration(for: session))")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button {
                    sessionToDelete = session
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                }
                .alert(item: $sessionToDelete) { session in
                    Alert(
                        title: Text("Күндік ояну мақсатын қайта орнатқыңыз келе ме?"),
                        primaryButton: .destructive(Text("Иә")) {
//                            viewModel.deleteSleepLog(log)
                        },
                        secondaryButton: .cancel(Text("Болдырмау"))
                    )
                }
            }
//            let resultText = """
//            🛌 Ұйықтаған уақыты: \(log.sleepTime)
//            🌅 Оянған уақыты: \(log.wakeTime)
//            """

//            Text(resultText)
//                .font(.system(size: 14, weight: .regular))
//                .foregroundColor(.white)
//                .multilineTextAlignment(.leading)
//            if let reason = log.customReason, !reason.isEmpty {
//                Text("📝 Себеп: \(reason)")
//                    .italic()
//                    .font(.system(size: 14, weight: .regular))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.leading)
//            }
        }
        .padding(16)
        .background(BlurredBackgroundView())
    }
}
