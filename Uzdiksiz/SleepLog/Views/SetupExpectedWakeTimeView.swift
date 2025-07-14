//
//  SetupExpectedWakeTimeView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//

import SwiftUI

struct SetupExpectedWakeTimeView: View {
    @ObservedObject var viewModel: SleepLogViewModel
    @State private var selectedTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 0))!

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Your Expected Wake Time")
                .font(.headline)

            DatePicker(
                "Wake Up Time",
                selection: $selectedTime,
                in: allowedRange,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .datePickerStyle(WheelDatePickerStyle())

            Button("Save Wake Time") {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let timeString = formatter.string(from: selectedTime)
                viewModel.saveExpectedWakeTime(timeString)
            }
            .padding()
        }
        .padding()
    }

    // 🔒 Only allow 04:00–10:00
    private var allowedRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(bySettingHour: 4, minute: 0, second: 0, of: now)!
        let end = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now)!
        return start...end
    }
}
