//
//  AddSleepLogPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 01.08.2025.
//
import SwiftUI

struct AddSleepLogPage: View {
    @Environment(\.dismiss) var dismiss
    @State var date: Date
    @State private var sleepTime = Date()
    @State private var wakeTime = Date()
    
    @State private var showDatePicker = false
    @State private var showSleepPicker = false
    @State private var showWakePicker = false

    let onSave: (Date, Time, Time) -> Void // date, sleepTime, wakeTime
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Ұйқы қосу")
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
            Spacer()
            Button {
                let sleep = Time(
                    hour: Calendar.current.component(.hour, from: sleepTime),
                    minute: Calendar.current.component(.minute, from: sleepTime)
                )
                let wake = Time(
                    hour: Calendar.current.component(.hour, from: wakeTime),
                    minute: Calendar.current.component(.minute, from: wakeTime)
                )
                onSave(date, sleep, wake)
                dismiss()
            } label: {
                DefaultButtonView(title: "Сақтау")
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
