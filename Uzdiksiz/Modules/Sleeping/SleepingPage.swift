//
//  SleepingPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 22.08.2025.
//

import SwiftUI

struct SleepingPage: View {
    @ObservedObject var viewModel: SleepingViewModel
    @State private var currentTime: Date = Date()
    private let alarmTime: Date = Calendar.current.date(bySettingHour: 5, minute: 0, second: 0, of: Date())!
    
    var timeRemaining: String {
        let now = Date()
        var target = alarmTime
        if now > target { // if already past 5 AM, calculate for next day
            target = Calendar.current.date(byAdding: .day, value: 1, to: target)!
        }
        let diff = Calendar.current.dateComponents([.hour, .minute], from: now, to: target)
        return String(format: "%02dh %02dm left", diff.hour ?? 0, diff.minute ?? 0)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.backgroundDeepNavy, .backgroundMidnightBlue], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    Text("Қайырлы түн!")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.textSoftWhite)
                    Text(currentTime, style: .time)
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(.textSoftWhite)
                }
                Image("sleeping_moon")
                    .resizable()
                    .scaledToFit()
                    .padding(32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        Image(systemName: "alarm.fill")
                            .font(.body.weight(.medium))
                            .foregroundColor(.textSoftWhite)
                        Text("Оятқыш 04:30")
                            .foregroundColor(.textSoftWhite)
                            .font(.body.weight(.medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.backgroundDeepNavy))
                    Text("5сағ 6мин қалды")
                        .font(.caption2)
                        .foregroundColor(.textLightGray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                LongPressButton(title: "Ояну") {
                    viewModel.wakeUp()
                }
            }
            .padding()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                currentTime = Date()
            }
        }
    }
}
