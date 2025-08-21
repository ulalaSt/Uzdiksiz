//
//  MinuteIntervalDatePicker.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 21.08.2025.
//

import SwiftUI

struct MinuteIntervalDatePicker: UIViewRepresentable {
    @Binding var date: Date
    var minuteInterval: Int = 5
    
    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.minuteInterval = minuteInterval
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(context.coordinator, action: #selector(Coordinator.updateDate(_:)), for: .valueChanged)
        return picker
    }
    
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = date
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: MinuteIntervalDatePicker
        
        init(_ parent: MinuteIntervalDatePicker) {
            self.parent = parent
        }
        
        @objc func updateDate(_ sender: UIDatePicker) {
            parent.date = sender.date
        }
    }
}
