//
//  TodayView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//

import SwiftUI

struct TodayView: View {
    @ObservedObject var viewModel: SleepLogViewModel
    
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
                        Text("Мақсат: \(expectedWakeTime) ояну")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(BlurredBackgroundView())
                }
                Group {
                    if let error = viewModel.expectedWakeTime.error {
                        Text(error.errorDescription)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                    } else if let data = viewModel.expectedWakeTime.value {
                        if let data {
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
                        } else {
                            SetupExpectedWakeTimeView(viewModel: viewModel)
                                .background(BlurredBackgroundView())
                        }
                    } else {
                        ProgressView("Ояну уақыты жүктелуде...")
                            .tint(.white)
                            .foregroundColor(.white)

                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .onAppear {
            if viewModel.expectedWakeTime == .notRequested {
                viewModel.fetchExpectedWakeTime()
                viewModel.fetchLogs()
            }
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "kk_KZ")
        formatter.dateFormat = "E, d MMMM" // Example: Дс, 7 шілде
        return formatter.string(from: Date())
    }
}
