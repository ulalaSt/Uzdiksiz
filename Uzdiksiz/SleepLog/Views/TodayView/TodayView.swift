//
//  TodayView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//

import SwiftUI

struct TodayView: View {
    @ObservedObject var viewModel: SleepLogViewModel
    @State private var logExists = false
    @State private var checking = true

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
                VStack(spacing: 32) {
                    Text("Қайырлы таң!")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Бүгін: \(formattedDate())")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(.white)
                    Group {
                        if viewModel.isLoading {
                            ProgressView("Ояну уақыты жүктелуде...")
                                .tint(.white)
                                .foregroundColor(.white)
                        } else if let _ = viewModel.expectedWakeTime {
                            Group {
                                if checking {
                                    ProgressView("Бүгінгі тіркелім тексерілуде...")
                                        .tint(.white)
                                        .foregroundColor(.white)
                                } else if !viewModel.logs.isEmpty, logExists {
                                    TodayResultView(viewModel: viewModel)
                                        .background(BlurredBackgroundView())
                                } else {
                                    LogSleepView(viewModel: viewModel) {
                                        logExists = true
                                    }
                                    .background(BlurredBackgroundView())
                                }
                            }
                            .onAppear {
                                viewModel.checkIfLogExistsForToday { exists in
                                    logExists = exists
                                    checking = false
                                }
                            }
                        } else {
                            SetupExpectedWakeTimeView(viewModel: viewModel)
                                .background(BlurredBackgroundView())
                        }
                    }
                    if let expectedWakeTime = viewModel.expectedWakeTime {
                        HStack(spacing: 10) {
                            if !viewModel.logs.isEmpty, let strike = viewModel.currentStrike(), strike > 0 {
                                Text("🔥 \(strike) күн қатар")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .medium))
                                Rectangle()
                                    .fill(.white.opacity(0.2))
                                    .frame(width: 1)
                            }
                            Text("Бекітілген ояну уақыты \(expectedWakeTime)")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(BlurredBackgroundView())
                    }
                    NavigationLink(destination: SleepHistoryView(viewModel: viewModel)) {
                        HStack {
                            Text("Ұйқы тарихы")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .foregroundColor(.white.opacity(0.2))
                                .frame(height: 17)
                        }
                        .padding(16)
                        .background(
                            BlurredBackgroundView()
                        )
                    }

                }
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            viewModel.fetchExpectedWakeTime()
            viewModel.fetchLogs()
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "kk_KZ")
        formatter.dateFormat = "E, d MMMM" // Example: Дс, 7 шілде
        return formatter.string(from: Date())
    }
}
