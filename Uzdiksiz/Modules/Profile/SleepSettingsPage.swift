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
    @State private var showAdvanceSheet = false
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                MinuteIntervalDatePicker(date: $sleepTimeDate)
                    .colorScheme(.dark)
                    .onChange(of: sleepTimeDate) { newValue in
                        viewModel.sleepTimeBinding.wrappedValue = sleepTime
                    }
                if viewModel.notificationPermissionGranted == true {
                    notificationSection
                } else {
                    
                }
            }
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
        
    var notificationSection: some View {
        VStack(spacing: 11) {
            if viewModel.notificationPermissionGranted == true {
                Button {
                    viewModel.openAppSettings()
                } label: {
                    VStack(spacing: 8) {
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "bell.slash.fill")
                                    .font(.body.weight(.semibold))
                                Text("Хабарламалар өшірілген")
                                    .font(.footnote.weight(.semibold))
                            }
                            .foregroundColor(.textSoftWhite)
                            Spacer()
                            HStack(spacing: 8) {
                                Text("Параметрлерге өту")
                                    .font(.caption)
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundColor(Color.textLightGray)
                        }
                        Text("Ұйқы уақытын еске салу үшін хабарламаларды қосыңыз. Бұл сізге уақытылы ұйықтауға көмектеседі.")
                            .font(.caption)
                            .foregroundColor(.textLightGray)
                            .multilineTextAlignment(.leading)
                    }
                    .contentShape(Rectangle())
                }
                Color.white.opacity(0.1).frame(height: 0.5)
            }
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bell")
                        .font(.body.weight(.semibold))
                    Text("Ескертпе")
                        .font(.footnote.weight(.semibold))
                }
                .foregroundColor(.textSoftWhite)
                Spacer()
                Toggle("", isOn: viewModel.isNotificationOnBinding)
                    .tint(Color.accentMediumSkyBlue)
                    .frame(height: 20)
            }
            .contentShape(Rectangle())
            .opacity(0.5)
            .disabled(viewModel.notificationPermissionGranted != true)
            Color.white.opacity(0.1).frame(height: 0.5)
            Button {
                showAdvanceSheet = true
            } label: {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.body.weight(.semibold))
                        Text("Алдын ала ескерту")
                            .font(.footnote.weight(.semibold))
                    }
                    .foregroundColor(.textSoftWhite)
                    Spacer()
                    HStack(spacing: 8) {
                        Text(viewModel.remindInAdvance.string)
                            .font(.caption)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(Color.textLightGray)
                }.contentShape(Rectangle())
            }
            .opacity(0.5)
            .disabled(viewModel.notificationPermissionGranted != true)
            .sheet(isPresented: $showAdvanceSheet) {
                NotificationAdvanceSheet(remindInAdvance: viewModel.remindInAdvanceBinding)
            }
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 16)
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
