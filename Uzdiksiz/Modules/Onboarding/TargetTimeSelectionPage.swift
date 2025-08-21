//
//  TargetTimeSelectionPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 18.08.2025.
//
import SwiftUI

struct TargetTimeSelectionPage: View {
    let onFinish: (Time, Time) -> Void
    @State var state: SelectionState = .sleep
    @State private var sleepTime: Date = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    @State private var wakeTime: Date = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? Date()
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack {
                Image("onboarding_moon")
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(state == .sleep ? .zero : Angle(radians: .pi / 2))
                    .opacity(state == .sleep ? 1 : 0)
                    .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5), value: state)
                Image("onboarding_sun")
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(state == .sleep ? -Angle(radians: .pi / 2) : .zero)
                    .opacity(state == .sleep ? 0 : 1)
                    .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5), value: state)
            }
            .frame(maxWidth: 150, maxHeight: 150, alignment: .center)
            .padding(.top, 32)
            TabView(selection: $state) {
                content(for: .sleep).tag(SelectionState.sleep)
                content(for: .wake).tag(SelectionState.wake)
            }.tabViewStyle(.page)
            Button {
                switch state {
                case .sleep:
                    withAnimation {
                        state = .wake
                    }
                case .wake:
                    let sleepComponents = Calendar.current.dateComponents([.hour, .minute], from: sleepTime)
                    let wakeComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeTime)
                    guard let sleepHour = sleepComponents.hour,
                          let sleepMinute = sleepComponents.minute,
                          let wakeHour = wakeComponents.hour,
                          let wakeMinute = wakeComponents.minute else {
                        return
                    }
                    onFinish(Time(hour: sleepHour, minute: sleepMinute), Time(hour: wakeHour, minute: wakeMinute))
                }
            } label: {
                DefaultButtonView(title: "Сақтау", state: .primary)
            }
            .padding(.bottom, 32)
            .padding(.horizontal, 32)
        }
        .background(LinearGradient(colors: [.backgroundDeepNavy, .backgroundMidnightBlue], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    func content(for state: SelectionState) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Text(state.title)
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.textSoftWhite)
            Text(state.description)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.textLightGray)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.backgroundDeepNavy))
            MinuteIntervalDatePicker(date: state == .sleep ? $sleepTime : $wakeTime)
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    enum SelectionState {
        case sleep
        case wake
        
        var title: String {
            switch self {
            case .sleep:
                "Қай уақытта ұйқыға жатасыз?"
            case .wake:
                "Қай уақытта оянғыңыз келеді?"
            }
        }
        
        var description: String {
            switch self {
            case .sleep:
                "🔔 Сізге ұйықтар алдын ескерту жібереміз!"
            case .wake:
                "⏰ Осы уақытқа оятқыш орнатамыз!"
            }
        }
    }
}

