//
//  SleepingPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 22.08.2025.
//

import SwiftUI

struct SleepingPage: View {
    @ObservedObject var timeViewModel: SleepTimeViewModel
    @ObservedObject var reportsViewModel: SleepReportViewModel
    @State private var currentTime: Date = Date()
    @State private var timer: Timer?
    let sleptDate: Date?

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: currentTime)
        switch hour {
        case 5..<12:
            return "Қайырлы таң!"
        case 12..<17:
            return "Қайырлы түс!"
        case 17..<22:
            return "Қайырлы кеш!"
        default:
            return "Қайырлы түн!"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                Text(greeting)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.textSoftWhite)
                Text(currentTime, style: .time)
                    .font(.system(size: 64, weight: .black))
                    .foregroundColor(.textSoftWhite)
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        if let sleptTimeString {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ұйқы уақыты")
                                    .font(.system(.caption2))
                                    .foregroundColor(.textLightGray)
                                HStack(spacing: 4) {
                                    Image(systemName: "bed.double.fill")
                                    Text("\(sleptTimeString)")
                                }
                                .font(.system(.body).weight(.medium))
                                .foregroundColor(.textSoftWhite)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.backgroundDeepNavy)
                            }
                        }
                        VStack(alignment: sleptTimeString == nil ? .center : .leading, spacing: 8) {
                            Text("Келесі оятқыш")
                                .font(.system(sleptTimeString == nil ? .caption : .caption2))
                                .foregroundColor(.textLightGray)
                            HStack(spacing: 4) {
                                Image(systemName: "alarm.fill")
                                Text("\(nextAlarmString)")
                            }
                            .font(.system(sleptTimeString == nil ? .title2 : .body).weight(.medium))
                            .foregroundColor(.colorsYellow)
                        }
                        .frame(maxWidth: .infinity, alignment: sleptTimeString == nil ? .center : .leading)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.backgroundDeepNavy)
                        }
                    }
                    if let nextAlarmRemainingString {
                        Text("Оянуға ")
                            .font(.system(.body))
                            .foregroundColor(.textLightGray)
                        + Text(nextAlarmRemainingString)
                            .font(.system(.body).weight(.medium))
                            .foregroundColor(.textSoftWhite)
                        + Text(" қалды")
                            .font(.system(.body))
                            .foregroundColor(.textLightGray)
                    } else {
                        Text("Уақыт өтті")
                            .font(.system(.body))
                            .foregroundColor(.textLightGray)
                    }
                }
            }
            Image("sleeping_moon")
                .resizable()
                .scaledToFit()
                .padding(32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(spacing: 10) {
                DefaultButtonView(title: "Ояну") {
                    Task {
                        do {
                            try await reportsViewModel.wakeUp()
                            timeViewModel.turnOffAlarm()
                        } catch {
                            print("Error waking up\(error)")
                        }
                    }
                }
            }
        }
        .padding()
        .backgroundGradient()
        .onAppear { startAdaptiveTimer() }
        .onDisappear {
            timer?.invalidate()
        }
    }
    var sleptTimeString: String? {
        if let sleptDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: sleptDate)
        }
        return nil
    }
    var nextAlarm: Date {
        if let date = AppState.shared.snoozeAlarmDate, date > currentTime {
            return date
        }
        return AppState.shared.wakeTime.nextDate
    }
    
    var nextAlarmString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: nextAlarm)
    }
    
    var nextAlarmRemainingString: String? {
        let target = nextAlarm
        let diff = Int(target.timeIntervalSince(currentTime)) // seconds
        
        if diff <= 0 {
            return nil
        }
        
        let hours = diff / 3600
        let minutes = (diff % 3600) / 60
        let seconds = diff % 60
        
        if hours > 0 {
            return "\(hours)сағ \(minutes)мин"
        } else {
            return "\(minutes)мин \(seconds)сек"
        }
    }
    
    private func startAdaptiveTimer() {
        timer?.invalidate()

        let diff = Int(nextAlarm.timeIntervalSince(Date()))
        let interval: TimeInterval = (diff > 3600) ? 30 : 1

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            currentTime = Date()
            // Re-check whether we need to switch from minute → second updates
            if diff > 3600 && nextAlarm.timeIntervalSince(Date()) <= 3600 {
                startAdaptiveTimer()
            }
        }
    }
}
