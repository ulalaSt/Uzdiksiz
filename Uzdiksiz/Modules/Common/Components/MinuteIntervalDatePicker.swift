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
    
    /// Optional snap closure to adjust invalid selection
    var snap: ((Date) -> Date)?
    
    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.minuteInterval = minuteInterval
        picker.preferredDatePickerStyle = .wheels
        picker.date = date
        picker.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        return picker
    }
    
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = date
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject {
        var parent: MinuteIntervalDatePicker
        init(_ parent: MinuteIntervalDatePicker) { self.parent = parent }
        
        @objc func changed(_ sender: UIDatePicker) {
            var selected = sender.date
            if let snap = parent.snap {
                selected = snap(selected)
                sender.setDate(selected, animated: true)
            }
            parent.date = selected
        }
    }
}


extension Date {
    /// Returns minutes since midnight
    var minutesSinceMidnight: Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    }
    
    /// Returns a Date today with given hour/minute
    static func from(hour: Int, minute: Int) -> Date {
        let comps = DateComponents(hour: hour, minute: minute)
        return Calendar.current.date(from: comps) ?? Date()
    }
}

/// Snap `time` outside a circular range around `center`
/// `beforeRange` = hours before center, `afterRange` = hours after center
func snapTime(_ time: Date, outsideCenter center: Date, beforeRange: Int, afterRange: Int) -> Date {
    let m = time.minutesSinceMidnight
    let c = center.minutesSinceMidnight
    
    // Compute difference in circular 24h clock
    let diff = (m - c + 1440) % 1440
    
    if diff <= afterRange * 60 { // inside after edge
        return center.addingTimeInterval(TimeInterval(afterRange * 3600))
    } else if diff > 1440 - beforeRange * 60 { // inside before edge
        return center.addingTimeInterval(TimeInterval(-beforeRange * 3600))
    } else {
        return time // valid
    }
}
