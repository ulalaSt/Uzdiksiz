//
//  LogSleepView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//
import SwiftUI

struct LogSleepView: View {
    @ObservedObject var viewModel: SleepLogViewModel
    @State private var sleepTime = Calendar.current.date(byAdding: .hour, value: -8, to: Date())!
    @State private var wakeTime = Date()
    @State private var reasonId: Int?
    @State private var customReason = ""
    @State private var showReasonPicker = false
    @State private var error = ""
    
    var onSuccess: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("🛌 Fill Today’s Sleep Log")
                .font(.title3)
                .padding(.bottom)

            DatePicker("Yesterday you fell asleep at", selection: $sleepTime, displayedComponents: .hourAndMinute)
            DatePicker("Today you woke up at", selection: $wakeTime, displayedComponents: .hourAndMinute)

            if showReasonPicker {
                Picker("Why did you wake up late?", selection: $reasonId) {
                    ForEach(0..<viewModel.reasons.count, id: \.self) { i in
                        Text(viewModel.reasons[i]).tag(i)
                    }
//                    Text("Other").tag(999)
                }
                .pickerStyle(.wheel)

                if reasonId == 2 {
                    TextField("Write your reason", text: $customReason)
                        .textFieldStyle(.roundedBorder)
                }
            }

            if !error.isEmpty {
                Text(error).foregroundColor(.red)
            }

            Button("Save Log") {
                saveLog()
            }
            .padding(.top)
        }
        .padding()
        .onChange(of: wakeTime) { _ in
            showReasonPicker = viewModel.shouldAskReason(actualWakeTime: wakeTime)
        }
    }

    func saveLog() {
        guard let expectedWakeTime = viewModel.expectedWakeTime else {
            return
        }
        
        if showReasonPicker && reasonId == nil {
            error = "Please select a reason."
            return
        }
        
        let log = SleepLog(
            date: viewModel.todayDateString(),
            sleepTime: viewModel.formatTime(sleepTime),
            wakeTime: viewModel.formatTime(wakeTime),
            expectedWakeTime: expectedWakeTime,
            reasonId: reasonId,
            customReason: reasonId == 999 ? customReason : nil,
            createdAt: Date()
        )

        viewModel.saveSleepLog(log)
    }
}
