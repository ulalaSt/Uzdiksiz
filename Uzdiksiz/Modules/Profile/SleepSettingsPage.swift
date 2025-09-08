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
        .backgroundGradient(ignoring: .all)
    }
    
    var sleepSettings: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                MinuteIntervalDatePicker(
                    date: $sleepTimeDate,
                    minuteInterval: 5,
                    snap: { selected in
                        snapTime(selected, outsideCenter: wakeTimeDate, beforeRange: 1, afterRange: 4)
                    }
                )
                notificationSection
            }
        }
    }
    
    var alarmSettings: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                MinuteIntervalDatePicker(
                    date: $wakeTimeDate,
                    minuteInterval: 5,
                    snap: { selected in
                        snapTime(selected, outsideCenter: sleepTimeDate, beforeRange: 4, afterRange: 1)
                    }
                )
                .colorScheme(.dark)
                .onChange(of: wakeTimeDate) { newValue in
                    viewModel.wakeTimeBinding.wrappedValue = wakeTime
                }
                alarmSection
            }
        }
    }
        
    var notificationSection: some View {
        VStack(spacing: 11) {
            if viewModel.notificationPermissionGranted != true {
                Button {
                    viewModel.openAppSettings()
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "bell.slash.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("Хабарламалар өшірілген")
                                    .font(.footnote.weight(.semibold))
                                    .multilineTextAlignment(.leading)
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
                            .padding(.leading, 30)
                    }
                    .contentShape(Rectangle())
                }
                Color.white.opacity(0.1).frame(height: 0.5)
            }
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
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
            .opacity(viewModel.notificationPermissionGranted == true ? 1 : 0.2)
            .disabled(viewModel.notificationPermissionGranted != true)
            Color.white.opacity(0.1).frame(height: 0.5)
            Button {
                showAdvanceSheet = true
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "timer")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
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
                    Text("Келесі ескертпе уақыты: \(viewModel.notificationTime.toString())")
                        .font(.caption)
                        .foregroundColor(.textLightGray)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 30)
                }
                .contentShape(Rectangle())
            }
            .opacity(viewModel.notificationPermissionGranted == true ? 1 : 0.2)
            .disabled(viewModel.notificationPermissionGranted != true)
            .sheet(isPresented: $showAdvanceSheet) {
                NotificationAdvanceSheet(remindInAdvance: viewModel.remindInAdvanceBinding)
            }
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 16)
        .background {
            Color.backgroundDeepNavy
        }
        .cornerRadius(16)
    }
    
    var alarmSection: some View {
        VStack(spacing: 11) {
            if viewModel.notificationPermissionGranted != true {
                Button {
                    viewModel.openAppSettings()
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "bell.slash.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("Хабарламалар өшірілген")
                                    .font(.footnote.weight(.semibold))
                                    .multilineTextAlignment(.leading)
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
                            .padding(.leading, 30)
                    }
                    .contentShape(Rectangle())
                }
                Color.white.opacity(0.1).frame(height: 0.5)
            }
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "alarm")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Оятқыш")
                        .font(.footnote.weight(.semibold))
                }
                .foregroundColor(.textSoftWhite)
                Spacer()
                Toggle("", isOn: viewModel.isNotificationOnBinding)
                    .tint(Color.accentMediumSkyBlue)
                    .frame(height: 20)
            }
            .contentShape(Rectangle())
            .opacity(viewModel.notificationPermissionGranted == true ? 1 : 0.2)
            .disabled(viewModel.notificationPermissionGranted != true)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 16)
        .background {
            Color.backgroundDeepNavy
        }
        .cornerRadius(16)
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
