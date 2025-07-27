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
                                        .background(transparentBg)
                                } else {
                                    LogSleepView(viewModel: viewModel) {
                                        logExists = true
                                    }
                                    .background(transparentBg)
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
                                .background(transparentBg)
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
                        .background(transparentBg)
                    }
                    NavigationLink(destination: SleepLogsView(viewModel: viewModel)) {
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
                            transparentBg
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
    
    var transparentBg: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 53/255, green: 63/255, blue: 84/255),   // #353F54
                Color(red: 34/255, green: 40/255, blue: 52/255)    // #222834
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.6)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white,
                            .black
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ).opacity(0.2), lineWidth: 2
                )
                .padding(1)
        })
        .shadow(
            color: Color(red: 59/255, green: 71/255, blue: 95/255).opacity(0.5),
            radius: 20,
            x: 0,
            y: -20
        )
        .shadow(
            color: Color(red: 16/255, green: 20/255, blue: 28/255).opacity(0.6),
            radius: 20,
            x: 0,
            y: 20
        )

    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "kk_KZ")
        formatter.dateFormat = "E, d MMMM" // Example: Дс, 7 шілде
        return formatter.string(from: Date())
    }
}
