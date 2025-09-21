//
//  TargetWakeTimeCreationView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 03.08.2025.
//

import SwiftUI

struct TargetWakeTimeCreationView: View {
    @ObservedObject var viewModel: SleepLogViewModel
    @State private var selectedTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 0))!
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 32) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Күн сайын оянғыңыз келетін уақытты таңдаңыз")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("Бұл сізге хабарлама жіберуімізге көмектеседі. Кейін өзгертуге болады.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer()
            DatePicker(
                "",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .colorScheme(.dark)
            .datePickerStyle(.wheel)
            Spacer()
            DefaultButtonView(title: "Ояну уақытын сақтау") {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let timeString = formatter.string(from: selectedTime)
                viewModel.saveExpectedWakeTime(timeString)
            }

        }
        .padding(24)
    }
}
