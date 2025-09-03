//
//  AddSleepLogView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 01.08.2025.
//
import SwiftUI

struct AddSleepLogView: View {
    @Environment(\.dismiss) var dismiss
    @State var date: Date
    @State private var sleepTime = Date()
    @State private var wakeTime = Date()
    
    let onSave: (Date, Time, Time) -> Void // date, sleepTime, wakeTime
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Күні", selection: $date, displayedComponents: .date)
                DatePicker("Ұйықтау уақыты", selection: $sleepTime, displayedComponents: .hourAndMinute)
                DatePicker("Ояну уақыты", selection: $wakeTime, displayedComponents: .hourAndMinute)
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

            }
            .scrollContentBackground(.hidden)
            .background(Color.backgroundDeepNavy
                .ignoresSafeArea())
            .navigationTitle("Жаңа ұйқы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Болдырмау") {
                        dismiss()
                    }
                    .foregroundColor(.textLightGray)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
