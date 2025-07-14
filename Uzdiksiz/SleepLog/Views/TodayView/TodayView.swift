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
        Group {
            if checking {
                ProgressView("Checking today’s log...")
            } else if logExists {
                TodayResultView(viewModel: viewModel)
            } else {
                LogSleepView(viewModel: viewModel) {
                    logExists = true
                }
            }
        }
        .navigationTitle("Today")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SleepLogsView(viewModel: viewModel)) {
                    Text("📋 Logs")
                }
            }
        }
        .onAppear {
            viewModel.checkIfLogExistsForToday { exists in
                logExists = exists
                checking = false
            }
        }
    }
}
