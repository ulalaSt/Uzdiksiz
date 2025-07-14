//
//  TodayResultView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//
import SwiftUI

struct TodayResultView: View {
    @ObservedObject var viewModel: SleepLogViewModel

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.wasOnTimeToday() {
                Text("👏 You woke up on time today!")
                    .font(.title2)
                    .foregroundColor(.green)
            } else {
                Text("😌 It's okay to miss a day.")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Try sleeping 30 mins earlier tonight.")
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}
