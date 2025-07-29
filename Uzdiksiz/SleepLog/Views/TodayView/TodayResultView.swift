//
//  TodayResultView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//
import SwiftUI

struct TodayResultView: View {
    @ObservedObject var viewModel: SleepLogViewModel
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Text(viewModel.wasOnTimeToday() ? "✅ Бүгінгі көрсеткіш" : "☑️ Бүгінгі көрсеткіш")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .alert("Бүгінгі ұйқы дерегін өшіргіңіз келе ме?", isPresented: $showDeleteAlert) {
                    Button("Өшіру", role: .destructive) {
                        viewModel.deleteTodayLog()
                    }
                    Button("Болдырмау", role: .cancel) {}
                }
            }
            if let text = viewModel.todaysResultText() {
                Text(text)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
    }
}
