//
//  AddSleepLogPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 01.08.2025.
//
import SwiftUI
enum AddSleepLogPageState {
    case edit(SleepSession)
    case add(date: Date)
    
    var isEditing: Bool {
        switch self {
        case .edit(let sleepSession):
            return true
        case .add(let date):
            return false
        }
    }
}

struct AddSleepLogPage: View {
    @Environment(\.dismiss) var dismiss
    private let state: AddSleepLogPageState
    @State var date: Date
    @State private var sleepTime: Date
    @State private var wakeTime: Date
    @State private var errorMessage: String?

    @State private var showDatePicker = false
    @State private var showSleepPicker = false
    @State private var showWakePicker = false
    init(state: AddSleepLogPageState, onSave: @escaping (Date, Time, Time) async throws -> Void) {
        self.state = state
        switch state {
        case .edit(let sleepSession):
            self._date = .init(initialValue: sleepSession.report?.date ?? Date())
            self._sleepTime = .init(initialValue: sleepSession.startTime.nextDate)
            self._wakeTime = .init(initialValue: sleepSession.endTime.nextDate)
        case .add(let date):
            self._date = .init(initialValue: date)
            self._sleepTime = .init(initialValue: Time.twentyTwo.nextDate)
            self._wakeTime = .init(initialValue: Time.five.nextDate)
        }
        self.onSave = onSave
    }
    let onSave: (Date, Time, Time) async throws -> Void

    var title: String {
        switch state {
        case .edit(let sleepSession):
            "Ұйқы өңдеу"
        case .add(let date):
            "Ұйқы қосу"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .padding(.vertical, 11)
                    .padding(.horizontal, 10)
                    .foregroundColor(.textSoftWhite)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Бас тарту")
                        .font(.headline.weight(.medium))
                        .padding(.vertical, 11)
                        .padding(.horizontal, 10)
                        .contentShape(Rectangle())
                        .foregroundColor(.textLightGray)
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Күні")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.textLightGray)
                    .padding(.leading, 10)
                
                Button {
                    showDatePicker = true
                } label: {
                    Text(date, style: .date)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.white.opacity(0.1).cornerRadius(12))
                        .foregroundColor(.textSoftWhite)
                        .font(.body)
                        .environment(\.locale, Locale(identifier: "kk_KZ"))
                }
                .popover(isPresented: $showDatePicker) {
                    ZStack {
                        Color.backgroundDeepNavy.scaleEffect(1.5)
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                        .environment(\.locale, Locale(identifier: "kk_KZ"))
                    }
                    .frame(width: 300, height: 300)
                    .presentationCompactAdaptation(.popover)
                    .colorScheme(.dark)
                    .preferredColorScheme(.dark)
                }
            }
            .disabled(state.isEditing)
            .opacity(state.isEditing ? 0.4 : 1)
            // MARK: Sleep & Wake Times
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ұйқы уақыты")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.textLightGray)
                        .padding(.leading, 10)
                    
                    Button {
                        showSleepPicker = true
                    } label: {
                        Text(sleepTime, style: .time)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.white.opacity(0.1).cornerRadius(12))
                            .foregroundColor(.textSoftWhite)
                            .font(.body)
                    }
                    .popover(isPresented: $showSleepPicker) {
                        ZStack {
                            Color.backgroundDeepNavy.scaleEffect(1.5)
                            DatePicker(
                                "Ұйқы уақыты",
                                selection: $sleepTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                        }
                        .presentationCompactAdaptation(.popover)
                        .colorScheme(.dark)
                        .preferredColorScheme(.dark)
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ояну уақыты")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.textLightGray)
                        .padding(.leading, 10)
                    
                    Button {
                        showWakePicker = true
                    } label: {
                        Text(wakeTime, style: .time)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.white.opacity(0.1).cornerRadius(12))
                            .foregroundColor(.textSoftWhite)
                        
                            .font(.body)
                    }
                    .popover(isPresented: $showWakePicker) {
                        ZStack {
                            Color.backgroundDeepNavy.scaleEffect(1.5)
                            DatePicker(
                                "Ояну уақыты",
                                selection: $wakeTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                        }
                        .presentationCompactAdaptation(.popover)
                        .colorScheme(.dark)
                        .preferredColorScheme(.dark)
                    }
                }
            }
            if let errorMessage {
                Text(errorMessage)
                    .font(.callout.weight(.medium))
                    .foregroundColor(.colorsRed)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            DefaultButtonView(title: "Сақтау") {
                let sleep = Time(
                    hour: Calendar.current.component(.hour, from: sleepTime),
                    minute: Calendar.current.component(.minute, from: sleepTime)
                )
                let wake = Time(
                    hour: Calendar.current.component(.hour, from: wakeTime),
                    minute: Calendar.current.component(.minute, from: wakeTime)
                )
                
                Task {
                    do {
                        try await onSave(date, sleep, wake)
                        await MainActor.run {
                            dismiss()
                        }
                    } catch SleepSessionError.overlappingSession(let conflictingSession) {
                        let start = String(format: "%02d:%02d", conflictingSession.startHour, conflictingSession.startMinute)
                        let end   = String(format: "%02d:%02d", conflictingSession.endHour, conflictingSession.endMinute)
                        await MainActor.run {
                            errorMessage = "Бұл уақыт басқа ұйқы жазбасымен қабаттасады: \(start) – \(end)."
                        }
                    } catch {
                        await MainActor.run {
                            errorMessage = "Қате: \(error.localizedDescription)"
                        }
                    }
                }
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .background(Color.backgroundDeepNavy.ignoresSafeArea())
        .colorScheme(.dark)
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)
        .presentationCornerRadius(40)
    }
}
