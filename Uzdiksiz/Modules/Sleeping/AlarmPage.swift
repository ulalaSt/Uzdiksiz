//
//  AlarmPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 22.08.2025.
//

import SwiftUI

struct AlarmPage: View {
    @ObservedObject var timeViewModel: SleepTimeViewModel
    @ObservedObject var reportsViewModel: SleepReportViewModel
    @State private var currentTime: Date = Date()
    @State private var isLoading: Bool = false
    
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
            VStack(spacing: 16) {
                Text(greeting)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.textSoftWhite)
                Text(currentTime, style: .time)
                    .font(.system(size: 64, weight: .black))
                    .foregroundColor(.textSoftWhite)
            }
            Image("time_flies_bro")
                .resizable()
                .scaledToFit()
                .padding(32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(spacing: 10) {
                DefaultButtonView(title: "5 минутқа жылжыту", state: .secondary) {
                    timeViewModel.snooze()
                }
                DefaultButtonView(title: "Ояндым", isLoading: isLoading, state: .primary) {
                    isLoading = true
                    Task {
                        do {
                            try await reportsViewModel.wakeUp()
                        } catch {
                            print("Error waking up\(error)")
                        }
                        timeViewModel.turnOffAlarm()
                    }
                }
//                Text("Ояну үшін басыңыз")
//                    .font(.body.weight(.medium))
//                    .foregroundColor(.textSoftWhite)
            }
        }
        .padding()
        .backgroundGradient()
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                currentTime = Date()
            }
        }
    }
}
