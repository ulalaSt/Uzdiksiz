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

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                if let expected = viewModel.expectedWakeTime.value, let expected {
                    Text("☀️ Бекітілген ояну уақыты: \(expected)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                if let logs = viewModel.logs.value {
                    if logs.isEmpty {
                        Text("💤 ӘЛІ ЖАЗБАЛАР ЖОҚ")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    } else {
                        ForEach(logs, id: \.createdAt) { log in
                            VStack(alignment: .leading) {
                                Text(log.wakeTime > log.expectedWakeTime ? "☑️ \(log.date)" : "✅ \(log.date)")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
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
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: Color(red: 52/255, green: 200/255, blue: 232/255), location: 0.0),
                                            .init(color: Color(red: 78/255, green: 74/255, blue: 242/255), location: 1),
                                        ]),
                                        startPoint: UnitPoint(x: 0.49, y: 0.0),
                                        endPoint: UnitPoint(x: 0.5, y: 1.0)
                                    )
                                )
                                .overlay(
                                    GeometryReader(content: { proxy in
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(
                                                LinearGradient(
                                                    gradient: Gradient(stops: [
                                                        .init(color: Color.white.opacity(0.6), location: 0.0),
                                                        .init(color: Color.black.opacity(0.6), location: 1)
                                                    ]),
                                                    startPoint: UnitPoint(x: 0.49, y: 0.0),
                                                    endPoint: UnitPoint(x: 0.5, y: 1.0)
                                                ),
                                                lineWidth: 2
                                            )
                                    })
                                )
                        )
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Ұйқы тарихы")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .background(bgView)
        .onAppear {
            viewModel.fetchLogs()
        }
    }
    
    var bgView: some View {
        Image("night_bg")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}
