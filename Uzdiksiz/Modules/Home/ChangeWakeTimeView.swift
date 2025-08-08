//
//  ChangeWakeTimeView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 01.08.2025.
//

import SwiftUI

struct ChangeWakeTimeView: View {
    @Binding var isPresented: Bool
    @State private var selectedTime: Date
    let onSave: (String) -> Void

    init(isPresented: Binding<Bool>, currentTimeString: String, onSave: @escaping (String) -> Void) {
        self._isPresented = isPresented
        self._selectedTime = State(initialValue: Self.timeStringToDate(currentTimeString) ?? Date())
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Жаңа мақсатты ояну уақытын таңдаңыз")
                .font(.headline)
                .padding(.top, 20)

            DatePicker(
                "Мақсатты уақыт",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()

            HStack {
                Button("Болдырмау") {
                    isPresented = false
                }
                .foregroundColor(.red)

                Spacer()

                Button("Сақтау") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    let timeString = formatter.string(from: selectedTime)
                    onSave(timeString)
                    isPresented = false
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding()
        .presentationDetents([.fraction(0.35)])
    }

    private static func timeStringToDate(_ time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: time)
    }
}
