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
    @State var logToDelete: SleepLog? = nil
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
                if let logs = viewModel.logs.value, !logs.isEmpty {
                    let avg = averageDuration(for: logs)
                    Text("📊 Орташа ұйқы ұзақтығы: \(avg.hour) сағ \(avg.minute) мин")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                
                if let logs = viewModel.logs.value {
                    if logs.isEmpty {
                        Text("💤 ӘЗІРГЕ ДЕРЕКТЕР ЖОҚ")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    } else {
                        let grouped = Dictionary(grouping: logs) { log -> Date in
                            return formatter.date(from: log.date) ?? Date.distantPast
                        }
                        let sortedGroups = grouped.sorted { $0.key > $1.key }

                        ForEach(sortedGroups, id: \.key) { date, logsForDate in
                            VStack(alignment: .leading, spacing: 16) {
                                Text("📅 \(formatter.string(from: date)) — \(formatDuration(logsForDate))")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.leading, 8)
                                ForEach(logsForDate) { log in
                                    VStack(alignment: .leading, spacing: 8) {
                                        cell(for: log)
                                    }
                                }
                            }
                        }
                        Button("CSV ретінде экспорттау") {
                            viewModel.exportSleepLogsCSV(logs: logs)
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
    
    func formatDuration(_ logsForDate: [SleepLog]) -> String {
        let (hour, minute) = viewModel.calculateTotalDuration(for: logsForDate)
        return "\(hour) сағ \(minute) мин"
    }

    func averageDuration(for logs: [SleepLog]) -> (hour: Int, minute: Int) {
        guard !logs.isEmpty else { return (0, 0) }

        let (totalHours, totalMinutes) = viewModel.calculateTotalDuration(for: logs)
        let totalMinutesAll = totalHours * 60 + totalMinutes

        // Вычисляем уникальные даты
        let uniqueDates = Set(logs.map { $0.date })
        guard !uniqueDates.isEmpty else { return (0, 0) }

        let averageMinutes = totalMinutesAll / uniqueDates.count
        return (averageMinutes / 60, averageMinutes % 60)
    }

    func cell(for log: SleepLog) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("😴 Ұйқы ұзақтығы: \(log.durationString)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button {
                    logToDelete = log
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                }
                .alert(item: $logToDelete) { log in
                    Alert(
                        title: Text("Күндік ояну мақсатын қайта орнатқыңыз келе ме?"),
                        primaryButton: .destructive(Text("Иә")) {
                            viewModel.deleteSleepLog(log)
                        },
                        secondaryButton: .cancel(Text("Болдырмау"))
                    )
                }
            }
            let resultText = """
            🛌 Ұйықтаған уақыты: \(log.sleepTime)
            🌅 Оянған уақыты: \(log.wakeTime)
            """

            Text(resultText)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            if let reason = log.customReason, !reason.isEmpty {
                Text("📝 Себеп: \(reason)")
                    .italic()
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(16)
        .background(BlurredBackgroundView())
    }
}
