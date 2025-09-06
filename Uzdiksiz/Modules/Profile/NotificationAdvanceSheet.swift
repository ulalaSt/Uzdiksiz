//
//  NotificationAdvanceSheet.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 05.09.2025.
//

import SwiftUI

struct NotificationAdvanceSheet: View {
    @Binding var remindInAdvance: Time
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempHour: Int
    @State private var tempMinute: Int
    
    let hours = Array(0...3)
    let minutes = stride(from: 0, through: 55, by: 5).map { $0 }
    
    // Өзгеріс бар-жоғын тексеру
    private var hasChanged: Bool {
        tempHour != remindInAdvance.hour || tempMinute != remindInAdvance.minute
    }
    
    // 🆕 Custom init
    init(remindInAdvance: Binding<Time>) {
        self._remindInAdvance = remindInAdvance
        _tempHour = State(initialValue: remindInAdvance.wrappedValue.hour)
        _tempMinute = State(initialValue: remindInAdvance.wrappedValue.minute)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Алдын ала ескерту")
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
            HStack {
                Picker("Сағат", selection: $tempHour) {
                    ForEach(hours, id: \.self) { h in
                        Text("\(h) сағ").tag(h)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                
                Picker("Минут", selection: $tempMinute) {
                    ForEach(minutes, id: \.self) { m in
                        Text("\(m) мин").tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 150)
            .padding(.vertical, 16)
            Button {
                remindInAdvance = Time(hour: tempHour, minute: tempMinute)
                dismiss()
            } label: {
                DefaultButtonView(title: "Сақтау", state: .primary)
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(16)
        .background(Color.backgroundDeepNavy.ignoresSafeArea())
        .presentationDetents([.height(330)])
        .presentationCornerRadius(40)
    }
}
