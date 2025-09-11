//
//  ClockFaceView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 21.08.2025.
//

import SwiftUI

struct ClockFaceView: View {
    let sleepTime: Time
    let wakeTime: Time
    let isDragging: Bool   // new
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2 - 10
            let center = CGPoint(x: geo.size.width/2, y: geo.size.height/2)
            
            ZStack {
                // Hour numbers
                ForEach(0..<24, id: \.self) { hour in
                    let angle = Angle.degrees(Double(hour) * 15 - 90) // 360/24 = 15°
                    let pos = CGPoint(
                        x: center.x + CGFloat(cos(angle.radians)) * (radius - 20),
                        y: center.y + CGFloat(sin(angle.radians)) * (radius - 20)
                    )
                    
                    Text("\(hour)")
                        .font(hour % 6 == 0 ? .caption2.weight(.bold) : .system(size: 8, weight: .medium))
                        .foregroundColor(hour % 6 == 0 ? .white : .white.opacity(0.2))
                        .position(pos)
                }
                
                // Sleep and Wake labels (show only when dragging)
                if isDragging {
                    let sleepAngle = Angle.degrees(Double(sleepTime.totalMinutes) / 60 * 15 - 90)
                    let wakeAngle  = Angle.degrees(Double(wakeTime.totalMinutes) / 60 * 15 - 90)
                    
                    let sleepPos = CGPoint(
                        x: center.x + CGFloat(cos(sleepAngle.radians)) * (radius - 30),
                        y: center.y + CGFloat(sin(sleepAngle.radians)) * (radius - 30)
                    )
                    
                    let wakePos = CGPoint(
                        x: center.x + CGFloat(cos(wakeAngle.radians)) * (radius - 30),
                        y: center.y + CGFloat(sin(wakeAngle.radians)) * (radius - 30)
                    )
                    
                    Text("\(String(format: "%02d:%02d", sleepTime.hour, sleepTime.minute))")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(Color.backgroundDeepNavy)
                        .padding(.horizontal, 3)
                        .background(Capsule().fill(Color.textSoftWhite))
                        .position(sleepPos)
                    
                    Text("\(String(format: "%02d:%02d", wakeTime.hour, wakeTime.minute))")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(Color.backgroundDeepNavy)
                        .padding(.horizontal, 3)
                        .background(Capsule().fill(Color.textSoftWhite))
                        .position(wakePos)
                }

                // Minute ticks (every 5 minutes = 288 around the circle)
                ForEach(0..<288, id: \.self) { tick in
                    tickLine(tick: tick, center: center, radius: radius)
                }
            }
            .frame(width: size, height: size)
        }
    }
    
    private func tickLine(tick: Int, center: CGPoint, radius: CGFloat) -> some View {
        let angle = Angle.degrees(Double(tick) * 1.25 - 90)
        let tickMinutes = tick * 5
        
        let hill = hillEffect(for: tickMinutes)
        let baseLength: CGFloat = 4        // minimum tick length
        let maxExtraLength: CGFloat = 8   // max growth from hill
        
        let isHourTick = tick % 12 == 0   // every 12 ticks = 1 hour (12*5=60 minutes)
        let hourExtraLength: CGFloat = isHourTick ? 4 : 0
        
        let tickLength = baseLength + (isDragging ? hill * maxExtraLength : 0) + hourExtraLength

        let startRadius = radius - tickLength
        let endRadius = radius
        
        let startPos = CGPoint(
            x: center.x + CGFloat(cos(angle.radians)) * startRadius,
            y: center.y + CGFloat(sin(angle.radians)) * startRadius
        )
        
        let endPos = CGPoint(
            x: center.x + CGFloat(cos(angle.radians)) * endRadius,
            y: center.y + CGFloat(sin(angle.radians)) * endRadius
        )
        
        return Path { path in
            path.move(to: startPos)
            path.addLine(to: endPos)
        }
        .stroke(Color.white.opacity(0.2), lineWidth: hill > 0 && isDragging ? 2 : 1)
        .animation(.easeInOut(duration: 0.1), value: hill)
    }

    // MARK: - Logic
    
    private func hillEffect(for tickMinutes: Int) -> CGFloat {
        let distToSleep = shortestDistance(from: tickMinutes, to: sleepTime.totalMinutes)
        let distToWake  = shortestDistance(from: tickMinutes, to: wakeTime.totalMinutes)
        
        let falloff: Double = 30 // influence zone in minutes
        
        func sharpFalloff(_ distance: Double) -> Double {
            if distance >= falloff { return 0 }
            let normalized = distance / falloff
            // sharper peak: raise to a higher power
            return pow(1.0 - normalized, 3) // cubic falloff, very sharp
        }
        
        let sleepHill = sharpFalloff(Double(distToSleep))
        let wakeHill  = sharpFalloff(Double(distToWake))
        
        return CGFloat(max(sleepHill, wakeHill))
    }

    private func shortestDistance(from a: Int, to b: Int) -> Int {
        var diff = abs(b - a)
        if diff > 720 { diff = 1440 - diff } // circular shortest path
        return diff
    }

    // MARK: - Helpers
    
    private func isInRange(minutes: Int, start: Int, end: Int) -> Bool {
        if start <= end {
            return minutes >= start && minutes <= end
        } else {
            return minutes >= start || minutes <= end
        }
    }
    
    private func distanceToInterval(minutes: Int, start: Int, end: Int) -> Int {
        if isInRange(minutes: minutes, start: start, end: end) {
            return 0
        }
        let d1 = abs(minutes - start)
        let d2 = abs(minutes - end)
        return min(d1, d2)
    }
}
