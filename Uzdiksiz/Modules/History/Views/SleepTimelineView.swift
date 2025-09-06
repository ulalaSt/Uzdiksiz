//
//  SleepTimelineView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 29.08.2025.
//

import SwiftUI

struct SleepTimelineView: View {
    let sessions: [SleepSession]
    
    private var minMinutes: Int {
        let base = Time(hour: 22, minute: 0).totalMinutes // yesterday 22:00
        let startCandidates = sessions.map { session -> Int in
            let start = session.startTime.totalMinutes
            return start >= base ? start : start + 24 * 60
        }
        return min(base, startCandidates.min() ?? 0)
    }

    private var maxMinutes: Int {
        let base = Time(hour: 22, minute: 0).totalMinutes + 24 * 60 // today 22:00
        let endCandidates = sessions.map { session -> Int in
            let end = session.endTime.totalMinutes
            return end < minMinutes ? end + 24 * 60 : end
        }
        return max(base, endCandidates.max() ?? 0)
    }

    private var totalMinutes: Int {
        maxMinutes - minMinutes
    }
    
    private func normalize(_ time: Time) -> Int {
        let minutes = time.totalMinutes
        return minutes < minMinutes ? minutes + 24 * 60 : minutes
    }

    private func relativeOffset(for minutes: Int, width: CGFloat) -> CGFloat {
        CGFloat(minutes - minMinutes) / CGFloat(totalMinutes) * width
    }
    
    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                let width = geo.size.width
                
                VStack(alignment: .leading, spacing: 4) {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .cornerRadius(3)
                        
                        ForEach(sessions) { session in
                            let start = normalize(session.startTime)
                            let end   = normalize(session.endTime)
                            
                            let startX = relativeOffset(for: start, width: width)
                            let endX   = relativeOffset(for: end, width: width)
                            let barWidth = max(0, endX - startX)
                            let isNap = session.minutesDuration < 30
                            Rectangle()
                                .fill(isNap ? Color.accentSkyIceBlue : Color.primaryOceanBlue)
                                .frame(width: barWidth)
                                .cornerRadius(3)
                                .offset(x: startX)
                        }
                    }
                    .frame(height: 20)
                    ZStack(alignment: .leading) {
                        let tickInterval: Int = {
                            if totalMinutes <= 6 * 60 { return 60 }   // every 1h
                            else if totalMinutes <= 12 * 60 { return 120 } // every 2h
                            else { return 240 } // every 4h
                        }()
                        
                        ForEach(Array(stride(from: minMinutes, through: maxMinutes, by: tickInterval)), id: \.self) { tick in
                            let x = relativeOffset(for: tick, width: width)
                            let hour = (tick / 60) % 24
                            let label = Text(String(format: "%02d", hour))
                                .font(.caption2)
                                .foregroundColor(Color.textLightGray)
                            if tick == minMinutes {
                                label.offset(x: x + 2) // shift right so it's inside
                            } else if tick == maxMinutes {
                                label.offset(x: x - 20) // shift left so it's inside
                            } else {
                                label.offset(x: x - 10) // center around tick normally
                            }
                        }
                    }
                    .frame(height: 14)
                }
            }
            .frame(height: 40) // bar + labels
        }
    }
}
