//
//  HomePage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//

import SwiftUI

struct HomePage: View {
    @ObservedObject var viewModel: SleepTimeViewModel
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(viewModel.todayString())
                .font(.title3.weight(.bold))
                .foregroundColor(.textLightGray)
            HStack(spacing: 16) {
                button(title: "Ұйқы", titleIcon: "bed.double.fill", titleIconColor: .accentBrightViolet, mainInfo: viewModel.sleepTime.toString(), description: viewModel.sleepTime.timeRemainingString ?? "Уақыт өтті")
                    .onTapGesture {
                        viewModel.openSettings(state: .sleep)
                    }
                button(title: "Оятқыш", titleIcon: "alarm.fill", titleIconColor: .colorsYellow, mainInfo: viewModel.wakeTime.toString(), description: viewModel.wakeTime.timeRemainingString ?? "Уақыт өтті")
                    .onTapGesture {
                        viewModel.openSettings(state: .wake)
                    }
            }
            SleepCircleView(sleepTime: viewModel.sleepTimeBinding, wakeTime: viewModel.wakeTimeBinding)
            Spacer()
            DefaultButtonView(title: "Қазір ұйықтау") {
                viewModel.startSleep()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundGradient(ignoring: .all)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
        
    func button(title: String, titleIcon: String, titleIconColor: Color, mainInfo: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: titleIcon)
                    .foregroundColor(titleIconColor)
                    .font(.caption2.weight(.medium))
                Text(title)
                    .foregroundColor(.textLightGray)
                    .font(.caption2.weight(.medium))
                Spacer()
                Image(systemName: "pencil.line")
                    .foregroundColor(.textLightGray)
                    .font(.caption2.weight(.medium))
            }
            VStack(alignment: .leading, spacing: 4){
                Text(mainInfo)
                    .foregroundColor(.textSoftWhite)
                    .font(.body.weight(.bold))
                Text(description)
                    .foregroundColor(.textLightGray)
                    .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .contentShape(Rectangle())
        .modify({ view in
            if #available(iOS 26.0, *), appState.isGlassEffectEnabled {
                view.glassEffect(.clear.interactive(), in: .rect(cornerRadius: 12))
            } else {
                view
                    .background(Color.backgroundDeepNavy)
                    .cornerRadius(12)
            }
        })
    }
}

