//
//  CalendarPopoverButton.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 08.09.2025.
//
import SwiftUI

struct CalendarPopoverButton: View {
    @State private var showingPopover = false
    @Binding var selectedDate: Date
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "kk_KZ")
        f.dateFormat = "EEE, d MMM"
        return f
    }()
    
    var progressForDate: (Date) -> Int

    var body: some View {
        Button {
            showingPopover = true
        } label: {
            HStack {
                Text(formatter.string(from: selectedDate).capitalized)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.textLightGray)
                Image("chevron_down_small")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.textLightGray)
            }
        }
        .contentShape(Rectangle())
        .popover(isPresented: $showingPopover) {
            MonthCalendarView(progressForDate: progressForDate, selectedDate: $selectedDate) { date in
                selectedDate = date
                showingPopover = false
            }
            .colorScheme(.dark)
            .preferredColorScheme(.dark)
            .presentationCompactAdaptation(.popover)
        }
    }
}
