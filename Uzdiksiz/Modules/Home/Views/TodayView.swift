//
//  TodayView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//

import SwiftUI

struct TodayView: View {
    @ObservedObject var viewModel: SleepLogViewModel
    @State private var showTimePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("Қайырлы таң!")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
                Text("Бүгін: \(formattedDate())")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.white)
                if let expectedWakeTime = viewModel.expectedWakeTime.value, let expectedWakeTime {
                    HStack(spacing: 10) {
                        if let logs = viewModel.logs.value, !logs.isEmpty, let strike = viewModel.currentStrike(), strike > 0 {
                            Text("🔥 \(strike) күн қатар")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .medium))
                            Rectangle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 1)
                        }
                        Text("🎯 Мақсат: \(expectedWakeTime) ояну")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        if let expectedWakeTime = viewModel.expectedWakeTime.value, let expectedWakeTime {
                            Button {
                                showTimePicker = true
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .sheet(isPresented: $showTimePicker) {
                                ChangeWakeTimeView(isPresented: $showTimePicker, currentTimeString: expectedWakeTime) { newTime in
                                    viewModel.saveExpectedWakeTime(newTime)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(BlurredBackgroundView())
                }
                Group {
                    if let error = viewModel.logs.error {
                            Text(error.errorDescription)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                    } else if let logs = viewModel.logs.value {
                        if let _ = logs.first(where: { $0.date == viewModel.todayDateString() }) {
                            TodayResultView(viewModel: viewModel)
                                .background(BlurredBackgroundView())
                        } else {
                            LogSleepView(viewModel: viewModel)
                                .background(BlurredBackgroundView())
                        }
                    } else {
                        ProgressView("Бүгінгі тіркелім тексерілуде...")
                            .tint(.white)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "kk_KZ")
        formatter.dateFormat = "E, d MMMM" // Example: Дс, 7 шілде
        return formatter.string(from: Date())
    }
}
