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
        VStack(spacing: 20) {
            Text("Алдын ала ескерту")
                .font(.title3.weight(.bold))
                .padding(.top, 16)
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
            
            Divider()
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    DefaultButtonView(title: "Бас тарту", state: .secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                Button {
                    remindInAdvance = Time(hour: tempHour, minute: tempMinute)
                    dismiss()
                } label: {
                    DefaultButtonView(title: "Сақтау", state: .primary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .opacity(hasChanged ? 1 : 0.7)
                .disabled(!hasChanged)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .presentationDetents([.height(340)])
    }
}
