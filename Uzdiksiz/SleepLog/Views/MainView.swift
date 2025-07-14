//
//  MainView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject var sleepLogViewModel = SleepLogViewModel()

    var body: some View {
        Group {
            if let _ = sleepLogViewModel.expectedWakeTime {
                TodayView(viewModel: sleepLogViewModel) // Main app view
            } else {
                SetupExpectedWakeTimeView(viewModel: sleepLogViewModel)
            }
        }
        .onAppear {
            sleepLogViewModel.fetchExpectedWakeTime()
        }
    }
}
