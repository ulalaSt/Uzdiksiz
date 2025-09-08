//
//  DayCell.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 08.09.2025.
//
import SwiftUI

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isWithinDisplayedMonth: Bool
    let progress: Double  // 0..1
    let dayTapped: (Date) -> Void
    let calendar = Calendar.current

    var dayNumber: String {
        let d = calendar.component(.day, from: date)
        return "\(d)"
    }

    var body: some View {
        let isToday = calendar.isDate(date, inSameDayAs: Date())
        Button(action: {
            dayTapped(date)
        }) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            isSelected ? Color.accentMediumSkyBlue : Color.primaryOceanBlue,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90)) // start from top
                    Text(dayNumber)
                        .foregroundColor((isToday || isSelected) ? .accentMediumSkyBlue : .textLightGray)
                        .font(.caption.weight(.medium))
                }
                .frame(width: 32, height: 32)
                Text("\(Int(round(progress * 100)))%")
                    .foregroundColor((isToday || isSelected) ? .accentMediumSkyBlue : .white.opacity(0.3))
                    .font(.caption2.weight(.medium))
                    .lineLimit(1)
            }
            .frame(maxWidth: 32)
            .padding(4)
            .contentShape(Rectangle())
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentMediumSkyBlue, lineWidth: 0.5)
                        .padding(0.25)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white.opacity(0.1))
                }
            }
            
        }
        .disabled(!isWithinDisplayedMonth)
        .opacity(isWithinDisplayedMonth ? 1.0 : 0.35)
    }
}
