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
                if let logs = viewModel.logs.value {
                    if logs.isEmpty {
                        Text("💤 ӘЗІРГЕ ДЕРЕКТЕР ЖОҚ")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    } else {
                        ForEach(logs, id: \.createdAt) { log in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(log.wakeTime > log.expectedWakeTime ? "☑️ \(log.date)" : "✅ \(log.date)")
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
                                Text(viewModel.resultText(for: log))
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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddLogSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
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
}
