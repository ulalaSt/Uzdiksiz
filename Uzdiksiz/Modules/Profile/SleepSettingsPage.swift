//
//  SleepSettingsPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 20.08.2025.
//

import SwiftUI

struct SleepSettingsPage: View {
    @State var state: SleepSettingsState
    @State var sleepTimeDate: Date
    @State var wakeTimeDate: Date
    @Environment(\.dismiss) var dismiss
    var wakeTime: Time {
        convertToTime(wakeTimeDate)
    }
    
    var sleepTime: Time {
        convertToTime(sleepTimeDate)
    }
    
    @ObservedObject var viewModel: SleepTimeViewModel
    
    init(state: SleepSettingsState, viewModel: SleepTimeViewModel) {
        self.state = state
        self.sleepTimeDate = viewModel.sleepTime.date
        self.wakeTimeDate = viewModel.wakeTime.date
        self.viewModel = viewModel
    }
    var body: some View {
        VStack(spacing: 16) {
            selector
            TabView(selection: $state) {
                sleepSettings.tag(SleepSettingsState.sleep)
                alarmSettings.tag(SleepSettingsState.wake)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 32)
        .navigationTitle("Ұйқы баптаулары")
        .navigationBarHidden(false)
        .colorScheme(.dark)
        .navigationBarBackButtonHidden()
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                Text("Ұйқы баптаулары")
                    .foregroundColor(.textSoftWhite)
                    .font(.headline.weight(.semibold))
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body)
                        .frame(width: 44, height: 44)
                        .foregroundColor(.textSoftWhite)
                }
            }
        })
        .backgroundGradient(ignoring: [.horizontal, .top])
    }
    
    var sleepSettings: some View {
        VStack(spacing: 16) {
            MinuteIntervalDatePicker(date: $sleepTimeDate)
                .colorScheme(.dark)
                .onChange(of: sleepTimeDate) { newValue in
                    viewModel.sleepTimeBinding.wrappedValue = sleepTime
                }
            Spacer()
        }
    }
    
    var alarmSettings: some View {
        VStack(spacing: 16) {
            MinuteIntervalDatePicker(date: $wakeTimeDate)
                .colorScheme(.dark)
                .onChange(of: wakeTimeDate) { newValue in
                    viewModel.wakeTimeBinding.wrappedValue = wakeTime
                }
            Spacer()
        }
    }
    
    var selector: some View {
        HStack(spacing: 0) {
            ForEach(SleepSettingsState.allCases) { sleepState in
                Button {
                    withAnimation {
                        state = sleepState
                    }
                } label: {
                    Text(sleepState.title)
                        .font(state == sleepState ? .body.weight(.semibold) : .body)
                        .foregroundColor(state == sleepState ? .textSoftWhite : .textLightGray)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .background {
                            if state == sleepState {
                                Capsule().fill(Color.primaryOceanBlue)
                            }
                        }
                }
            }
        }
        .background(Capsule().fill(.white.opacity(0.1)))
    }
    
    func convertToTime(_ date: Date) -> Time {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else {
            return .zero
        }
        return Time(hour: hour, minute: minute)
    }
}
