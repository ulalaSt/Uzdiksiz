//
//  HomePage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//

import SwiftUI

struct HomePage: View {
    @ObservedObject var viewModel: SleepTimeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(viewModel.todayString())
                .font(.title3.weight(.bold))
                .foregroundColor(.textLightGray)
            Image("24_clock")
                .resizable()
                .scaledToFit()
                .padding(32)
                .background(
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 32)
                        .padding(16)
                )
                .overlay {
                    GeometryReader { proxy in
                        let radius = proxy.size.width / 2
                        Circle()
                            .stroke(RadialGradient(colors: [.black.opacity(0.25), .clear, .clear, .black.opacity(0.25)], center: .center, startRadius: radius - 32, endRadius: radius), lineWidth: 32)
                            .padding(16)
                    }
                }
                .overlay {
                    alarmController
                }
                .padding(.horizontal, 24)
            
            HStack(spacing: 16) {
                Button {
                    viewModel.openSettings(state: .sleep)
                } label: {
                    button(title: "Ұйқы", titleIcon: "bed.double.fill", titleIconColor: .accentBrightViolet, mainInfo: viewModel.sleepTime.toString(), description: viewModel.timeLeft(for: .sleep).toString(isDiff: true))
                }
                Button {
                    viewModel.openSettings(state: .wake)
                } label: {
                    button(title: "Оятқыш", titleIcon: "alarm.fill", titleIconColor: .colorsYellow, mainInfo: viewModel.wakeTime.toString(), description: viewModel.timeLeft(for: .wake).toString(isDiff: true))
                }
            }
            Spacer()
            Button {
                
            } label: {
                DefaultButtonView(title: "Қазір ұйықтау")
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(colors: [.backgroundDeepNavy, .backgroundMidnightBlue], startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea([.horizontal, .top]))
        .navigationBarHidden(true)
    }
    
    var alarmController: some View {
        Circle()
            .fill(Color.textSoftWhite)
            .overlay {
                Circle()
                    .stroke(Color.primaryOceanBlue.opacity(0.15), lineWidth: 3)
                    .padding(1.5)
                Image(systemName: "alarm.fill")
                    .font(.body)
                    .foregroundColor(Color.primarySapphireBlue)
            }
            .frame(width: 44, height: 44)
        //                            .frame(maxHeight: .infinity, alignment: .top)
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
        .background(Color.backgroundDeepNavy)
        .cornerRadius(12)
    }
}
