//
//  AddSleepLogView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 01.08.2025.
//
import SwiftUI

struct AddSleepLogView: View {
    @Environment(\.dismiss) var dismiss
    @State private var date = Date()
    @State private var sleepTime = Date()
    @State private var wakeTime = Date()
    
    let onSave: (String, String, String) -> Void // date, sleepTime, wakeTime
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Күні", selection: $date, displayedComponents: .date)
                DatePicker("Ұйықтау уақыты", selection: $sleepTime, displayedComponents: .hourAndMinute)
                DatePicker("Ояну уақыты", selection: $wakeTime, displayedComponents: .hourAndMinute)
            }
            .navigationTitle("Жаңа жазба")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Болдырмау") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сақтау") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateStr = formatter.string(from: date)
                        
                        let timeFormatter = DateFormatter()
                        timeFormatter.dateFormat = "HH:mm"
                        let sleepStr = timeFormatter.string(from: sleepTime)
                        let wakeStr = timeFormatter.string(from: wakeTime)
                        
                        onSave(dateStr, sleepStr, wakeStr)
                        dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
