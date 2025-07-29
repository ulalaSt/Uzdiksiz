//
//  LogSleepView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//
import SwiftUI

struct LogSleepView: View {
    @ObservedObject var viewModel: SleepLogViewModel
    @State private var sleepTime: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.day! -= 1  // next day
        components.hour = 22
        components.minute = 0
        return Calendar.current.date(from: components)!
    }()

    @State private var wakeTime: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components)!
    }()
    @State private var reasonId: Int?
    @State private var customReason = ""
    @State private var showReasonPicker = false
    @State private var error = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("🛌 Бүгінгі ұйқы деректерін енгізіңіз")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            HStack(spacing: 10) {
                VStack(spacing: 10) {
                    Text("ҰЙЫҚТАДЫМ")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                    DatePicker("", selection: $sleepTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .colorScheme(.dark)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(innerShadowBg)
                VStack(spacing: 10) {
                    Text("ОЯНДЫМ")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                    DatePicker("", selection: $wakeTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .colorScheme(.dark)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(innerShadowBg)
            }
            if showReasonPicker {
                Picker("Неге кеш ояндыңыз?", selection: $reasonId) {
                    ForEach(0..<viewModel.reasons.count, id: \.self) { i in
                        Text(viewModel.reasons[i]).tag(i)
                    }
                    Text("Other").tag(999)
                }
                .pickerStyle(.inline)
                if reasonId == 999 {
                    TextField("😓 Кеш тұру себебі", text: $customReason, prompt: Text("Себебіңізді жазыңыз").foregroundColor(Color(red: 125/255, green: 125/255, blue: 145/255)))
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                        .autocapitalization(.none)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(innerShadowBg)
                        .cornerRadius(10)
                }
            }

            if !error.isEmpty {
                Text(error).foregroundColor(.red)
            }

            Button {
                saveLog()
            } label: {
                DefaultButtonView(title: "Сақтау")
            }
        }
        .padding(16)
        .onChange(of: wakeTime) { _ in
            showReasonPicker = viewModel.shouldAskReason(actualWakeTime: wakeTime)
        }
    }

    var innerShadowBg: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(red: 40/255, green: 48/255, blue: 63/255))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white,
                            lineWidth: 32)
                    .padding(-16)
                    .shadow(color: Color(red: 25/255, green: 30/255, blue: 40/255),
                            radius: 6, x: 4, y: 4)
                    .shadow(color: Color(red: 54/255, green: 64/255, blue: 85/255), radius: 3, x: -4, y: -4)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )
            )
    }

    func saveLog() {
        if showReasonPicker {
            if reasonId == nil {
                error = "Себепті таңдаңыз"
                return
            } else if customReason.isEmpty {
                error = "Кешігу себебін толтырыңыз"
                return
            }
        }

        viewModel.saveSleepLog(wakeTime: wakeTime, sleepTime: sleepTime, reasonId: reasonId, customReason: customReason)
    }
}
