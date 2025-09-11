//
//  SleepCircleView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 21.08.2025.
//


import SwiftUI

struct SleepCircleView: View {
    @Binding var sleepTime: Time
    @Binding var wakeTime: Time
    @State private var isDragging = false

    let minDurationMinutes = 60    // 1h
    let maxDurationMinutes = 20*60 // 20h
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width/2, y: geo.size.height/2)
            let radius = size/2

            ZStack {
                ClockFaceView(sleepTime: sleepTime, wakeTime: wakeTime, isDragging: isDragging)
                    .padding(16)
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 32)
                // Arc between sleep and wake
                Path { path in
                    path.addArc(center: center,
                                radius: radius,
                                startAngle: angle(for: sleepTime),
                                endAngle: angle(for: wakeTime),
                                clockwise: false)
                }
                .stroke(Color.primaryOceanBlue, lineWidth: 32)
                .frame(width: geo.size.width, height: geo.size.height)
                Circle()
                    .stroke(RadialGradient(colors: [.black.opacity(0.25), .clear, .clear, .black.opacity(0.25)], center: .center, startRadius: radius - 16, endRadius: radius + 16), lineWidth: 32)
                let currentAngle = angle(for: Time.current)
                Image(systemName: "figure.walk")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 16)
                    .foregroundColor(.white.opacity(0.25))
                    .rotationEffect(currentAngle + .degrees(90))
                    .position(
                        x: center.x + cos(CGFloat(currentAngle.radians)) * radius,
                        y: center.y + sin(CGFloat(currentAngle.radians)) * radius
                    )
                handle(imageName: "bed.double", at: angle(for: sleepTime), center: center, radius: radius)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                let newTime = time(for: value.location, center: center)
                                updateSleepTime(newTime)
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                
                // Wake handle
                handle(imageName: "alarm", at: angle(for: wakeTime), center: center, radius: radius)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                let newTime = time(for: value.location, center: center)
                                updateWakeTime(newTime)
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                VStack(spacing: 0) {
                    Text(String(format: "%02d", durationMinutes / 60)).font(.system(size: 48, weight: .heavy)) + Text("сағ").font(.title3.weight(.bold))
                    Text(String(format: "%02d мин", durationMinutes % 60))
                        .font(.caption.weight(.medium))
                        .foregroundColor(.textSoftWhite)
                }
                .foregroundColor(.textSoftWhite)

            }
            .frame(width: size, height: size)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity) // take all available space
        .aspectRatio(1, contentMode: .fit) // make it square
    }
    
    // MARK: - Computed
    
    private var durationMinutes: Int {
        var diff = wakeTime.totalMinutes - sleepTime.totalMinutes
        if diff < 0 { diff += 24*60 }
        return diff
    }
    
    // MARK: - Conversions
    
    private func angle(for time: Time) -> Angle {
        let degrees = Double(time.totalMinutes) / 4.0 // 1440min → 360°, so 1min = 0.25°
        return .degrees(degrees - 90) // shift so midnight is at top
    }
    
    private func time(for location: CGPoint, center: CGPoint) -> Time {
        let dx = location.x - center.x
        let dy = location.y - center.y
        var degrees = atan2(dy, dx) * 180 / .pi
        degrees += 90
        if degrees < 0 { degrees += 360 }
        
        var totalMinutes = Int(degrees * 4) % 1440
        // snap to 5-minute increments
        totalMinutes = (totalMinutes / 5) * 5
        
        return Time.fromMinutes(totalMinutes)
    }

    private func updateSleepTime(_ newTime: Time) {
        let newDuration = minutesDifference(from: newTime, to: wakeTime)

        if newDuration < minDurationMinutes {
            // too small → push wakeTime forward
            let adjustedWake = Time.fromMinutes((newTime.totalMinutes + minDurationMinutes) % 1440)
            if wakeTime != adjustedWake {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                wakeTime = adjustedWake
            }
            sleepTime = newTime
        } else if newDuration > maxDurationMinutes {
            // too big → pull wakeTime closer
            let adjustedWake = Time.fromMinutes((newTime.totalMinutes + maxDurationMinutes) % 1440)
            if wakeTime != adjustedWake {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                wakeTime = adjustedWake
            }
            sleepTime = newTime
        } else {
            if newTime != sleepTime {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                sleepTime = newTime
            }
        }
    }

    private func updateWakeTime(_ newTime: Time) {
        let newDuration = minutesDifference(from: sleepTime, to: newTime)

        if newDuration < minDurationMinutes {
            // too small → push sleepTime backward
            let adjustedSleep = Time.fromMinutes((newTime.totalMinutes - minDurationMinutes + 1440) % 1440)
            if sleepTime != adjustedSleep {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                sleepTime = adjustedSleep
            }
            wakeTime = newTime
        } else if newDuration > maxDurationMinutes {
            // too big → pull sleepTime closer
            let adjustedSleep = Time.fromMinutes((newTime.totalMinutes - maxDurationMinutes + 1440) % 1440)
            if sleepTime != adjustedSleep {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                sleepTime = adjustedSleep
            }
            wakeTime = newTime
        } else {
            if newTime != wakeTime {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                wakeTime = newTime
            }
        }
    }

    private func minutesDifference(from start: Time, to end: Time) -> Int {
        var diff = end.totalMinutes - start.totalMinutes
        if diff < 0 { diff += 24*60 }
        return diff
    }
    
    private func handle(imageName: String, at angle: Angle, center: CGPoint, radius: CGFloat) -> some View {
        Circle()
            .fill(Color.textSoftWhite)
            .overlay {
                Circle()
                    .stroke(Color.primaryOceanBlue.opacity(0.15), lineWidth: 3)
                    .padding(1.5)
                Image(systemName: imageName)
                    .font(.body)
                    .foregroundColor(Color.primarySapphireBlue)
            }
            .frame(width: 40, height: 40)
            .position(
                x: center.x + cos(CGFloat(angle.radians)) * radius,
                y: center.y + sin(CGFloat(angle.radians)) * radius
            )
            .shadow(radius: 5)
    }
}

