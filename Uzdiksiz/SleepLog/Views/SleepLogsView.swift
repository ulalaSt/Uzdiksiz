//
//  SleepLogsView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//
import SwiftUI

struct SleepLogsView: View {
    @ObservedObject var viewModel: SleepLogViewModel

    var body: some View {
        VStack {
            if let expected = viewModel.expectedWakeTime {
                Text("☀️ Expected Wake Time: \(expected)")
                    .font(.subheadline)
                    .padding(.horizontal)
            }
            
            if viewModel.logs.isEmpty {
                Text("💤 NO LOGS YET")
                Spacer()
            } else {
                List(viewModel.logs, id: \.createdAt) { log in
                    VStack(alignment: .leading) {
                        Text("📅 \(log.date)")
                            .font(.headline)
                        Text("💤 Sleep: \(log.sleepTime) → \(log.wakeTime)")
                        if let reason = log.customReason, !reason.isEmpty {
                            Text("📝 Reason: \(reason)").italic()
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            Button("Add Sleep Log") {
                let sample = SleepLog(
                    date: "2025-07-13",
                    sleepTime: "23:40",
                    wakeTime: "08:15",
                    expectedWakeTime: "07:00",
                    reasonId: nil,
                    customReason: "Felt sick",
                    createdAt: Date()
                )
                viewModel.saveSleepLog(sample)
            }
        }
        .padding()
        .navigationTitle("Sleep Logs")
        .onAppear {
            viewModel.fetchLogs()
        }
    }
}
