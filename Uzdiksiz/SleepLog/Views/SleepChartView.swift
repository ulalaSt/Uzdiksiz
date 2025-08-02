//
//  SleepChartView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 30.07.2025.
//
import SwiftUI
import Charts

struct SleepChartView: View {
    struct SleepEntry: Identifiable {
        let id: String
        let date: Date
        let sleep: Date
        let wake: Date
        let isPrimary: Bool
    }
    
    @StateObject var locationManager = LocationManager()
    @State var sunrise: Date? = nil
    @State var sunset: Date? = nil
    @Environment(\.dismiss) var dismiss
    let logs: [SleepLog]
    let targetWakeTime: String
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }()
    
    let nightColor = Color(red: 0/255, green: 9/255, blue: 45/255)
    let dayColor   = Color(red: 2/255, green: 25/255, blue: 68/255)

    var sleepWakePairs: [SleepEntry] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current

        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let rawPairs: [(id: String, date: Date, sleep: Date, wake: Date)] = logs.compactMap { log in
            guard let date = formatter.date(from: log.date),
                  let sleep = timeToDate(log.sleepTime, reference: log.sleepTime > log.wakeTime ? yesterday : today),
                  let wake = timeToDate(log.wakeTime, reference: today) else {
                return nil
            }
            return (log.id, date, sleep, wake)
        }

        let grouped = Dictionary(grouping: rawPairs, by: { calendar.startOfDay(for: $0.date) })

        var result: [SleepEntry] = []
        for (_, entries) in grouped {
            let sorted = entries.sorted { $0.sleep < $1.sleep }
            for (index, e) in sorted.enumerated() {
                result.append(SleepEntry(id: e.id, date: e.date, sleep: e.sleep, wake: e.wake, isPrimary: index == 0))
            }
        }
        return result.sorted { $0.date < $1.date }
    }

    var minY: Date {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let twenty = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: yesterday)!

        if let earliestSleep = sleepWakePairs.map({ $0.sleep }).min() {
            let twentyOne = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: yesterday)!
            if earliestSleep < twentyOne {
                return earliestSleep.addingTimeInterval(-3600) // subtract 1 hour
            }
        }

        return twenty
    }
    
    var maxY: Date {
        let today = calendar.startOfDay(for: Date())
        let nineteen = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: today)!
        let twenty = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today)!

        if let latestWake = sleepWakePairs.map({ $0.wake }).max() {
            if latestWake > nineteen {
                return latestWake.addingTimeInterval(3600)
            }
        }

        return twenty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    if let sunrise, let sunset {
                        VStack(spacing: 0) {
                            backgroundColor(sunrise: sunrise, sunset: sunset, date: minY)
                                .frame(height: geo.safeAreaInsets.top)
                                .ignoresSafeArea()
                            gradientBackground(sunrise: sunrise, sunset: sunset, min: minY, max: maxY)
                            backgroundColor(sunrise: sunrise, sunset: sunset, date: maxY)
                                .frame(height: geo.safeAreaInsets.bottom)
                                .ignoresSafeArea()
                        }.ignoresSafeArea()
                    }
                    let contentWidth = CGFloat(sleepWakePairs.count) * 60
                    if #available(iOS 17, *) {
                        if let lastWake = sleepWakePairs.last?.wake {
                            chart
                                .chartScrollableAxes(.horizontal)
                                .chartXVisibleDomain(length: 86400*7)
                                .chartScrollPosition(initialX: lastWake)
                                .padding(.horizontal, 16)
                        }
                    } else {
                        if contentWidth > geo.size.width - 32 {
                            ScrollView(.horizontal, showsIndicators: false) {
                                chart
                                    .frame(width: CGFloat(sleepWakePairs.count) * 60)
                                    .padding(.horizontal, 16)
                            }
                        } else {
                            chart
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .frame(width: 24, height: 10)
                    Image(systemName: "alarm.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                    Text("Мақсат: \(targetWakeTime)")
                        .font(.system(size: 12))
                }
                .foregroundColor(.red)
                if let sunrise {
                    HStack(spacing: 6) {
                        Line()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .frame(width: 24, height: 10)
                        Image(systemName: "sunrise.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                        Text("Күн шығуы: \(sunrise.formatted(.dateTime.hour().minute()))")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.yellow)
                }
                if let sunset {
                    HStack(spacing: 6) {
                        Line()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .frame(width: 24, height: 10)
                        Image(systemName: "sunset.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                        Text("Күн бату: \(sunset.formatted(.dateTime.hour().minute()))")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(0.6)
            .background {
                if let sunrise, let sunset {
                    backgroundColor(sunrise: sunrise, sunset: sunset, date: maxY)
                        .ignoresSafeArea()
                }
            }
        }
        .padding(.vertical, 16)
        .onReceive(locationManager.$location.compactMap { $0 }) { location in
            if sunrise == nil || sunset == nil {
                let (rise, set) = locationManager.getSunriseSunsetStrings(for: location)
                self.sunrise = rise
                self.sunset = set
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    BackButton()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Ұйқы графигі")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    var chart: some View {
        Chart {
            if let targetWakeDate = timeToDate(targetWakeTime, reference: .now) {
                RuleMark(
                    y: .value("Target Wake Time", targetWakeDate)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                .foregroundStyle(.red.opacity(0.5))
            }
            if let sunrise {
                RuleMark(
                    y: .value("Sunrise", sunrise)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                .foregroundStyle(.orange.opacity(0.5))
            }
            if let sunset {
                RuleMark(
                    y: .value("Sunset", sunset)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                .foregroundStyle(.white)
            }
            ForEach(sleepWakePairs) { entry in
                BarMark(
                    x: .value("Date", entry.date, unit: .day),
                    yStart: .value("Sleep", entry.sleep),
                    yEnd: .value("Wake", entry.wake),
                    width: .fixed(12)
                )
                .foregroundStyle(entry.isPrimary ? Color.cyan.gradient : Color.cyan.opacity(0.3).gradient)
                .annotation(position: .bottom) {
                    Text(entry.wake.formatted(.dateTime.hour().minute()))
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 2)
                        .background {
                            RoundedRectangle(cornerRadius: 2).fill(nightColor)
                        }
                        .opacity(entry.isPrimary ? 1 : 0.3)
                }
                .annotation(position: .top) {
                    Text(entry.sleep.formatted(.dateTime.hour().minute()))
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 2)
                        .background {
                            RoundedRectangle(cornerRadius: 2).fill(nightColor)
                        }
                        .opacity(entry.isPrimary ? 1 : 0.3)
                }
                .annotation(position: .overlay, alignment: .center) {
                    let duration = entry.wake.timeIntervalSince(entry.sleep)
                    let hours = Int(duration) / 3600
                    let minutes = (Int(duration) % 3600) / 60
                    let durationText = "\(hours) сағ"
                    Text(minutes == 0 ? durationText : durationText + " \(minutes) мин")
                        .fixedSize()
                        .font(.caption2.bold())
                        .foregroundColor(nightColor)
                        .rotationEffect(.degrees(-90)) // Поворот текста
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks(
                position: .leading,
                values: Array(stride(from: minY, through: maxY, by: 1800)) // 30 minutes
            ) { value in
                if let val = value.as(Date.self) {
                    let components = calendar.dateComponents([.minute], from: val)
                    let isHalfHour = components.minute == 30

                    if isHalfHour {
                        // Only grid line, no label
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                    } else {
                        // Grid line + label on full hour
                        AxisGridLine()
                        AxisValueLabel {
                            Text(val, format: .dateTime.hour().minute())
                        }
                    }
                }
            }
        }
        .chartYScale(domain: minY...maxY)
    }
    
    var sunriseBefore: Double = 3600
    var sunriseAfter: Double = 3600
    var sunsetBefore: Double = 3600
    var sunsetAfter: Double = 3600
    
    func backgroundColor(sunrise: Date, sunset: Date, date: Date) -> Color {
        let sunriseComponents = calendar.dateComponents([.hour, .minute], from: sunrise)
        let sunsetComponents = calendar.dateComponents([.hour, .minute], from: sunset)

        guard let todaySunrise = calendar.date(bySettingHour: sunriseComponents.hour!, minute: sunriseComponents.minute!, second: 0, of: date),
              let todaySunset = calendar.date(bySettingHour: sunsetComponents.hour!, minute: sunsetComponents.minute!, second: 0, of: date) else {
            return Color(red: 0.05, green: 0.07, blue: 0.1) // Ночь
        }

        let sunriseStart = todaySunrise.addingTimeInterval(-sunriseBefore)
        let sunriseEnd = todaySunrise.addingTimeInterval(sunriseAfter)
        let sunsetStart = todaySunset.addingTimeInterval(-sunsetBefore)
        let sunsetEnd = todaySunset.addingTimeInterval(sunsetAfter)
        
        if date <= sunriseStart || date >= sunsetEnd {
            return nightColor
        } else if date > sunriseStart && date < sunriseEnd {
            let t = date.timeIntervalSince(sunriseStart) / sunriseEnd.timeIntervalSince(sunriseStart)
            return Color.lerp(from: nightColor, to: dayColor, t: t)
        } else if date >= sunriseEnd && date <= sunsetStart {
            return dayColor
        } else if date > sunsetStart && date < sunsetEnd {
            let t = date.timeIntervalSince(sunsetStart) / sunsetEnd.timeIntervalSince(sunsetStart)
            return Color.lerp(from: dayColor, to: nightColor, t: t)
        } else {
            return nightColor
        }
    }

    func gradientBackground(sunrise: Date, sunset: Date, min: Date, max: Date) -> some View {
        let total = max.timeIntervalSince(min)
        guard total > 0 else {
            return LinearGradient(colors: [.black], startPoint: .top, endPoint: .bottom)
        }

        func normalized(_ date: Date) -> CGFloat {
            return CGFloat((date.timeIntervalSince(min)) / total)
        }
        func dateWithTime(from time: Date, on day: Date) -> Date? {
            let components = calendar.dateComponents([.hour, .minute, .second], from: time)
            return calendar.date(bySettingHour: components.hour!, minute: components.minute!, second: components.second!, of: day)
        }

        var keyDates: [Date] = [min, max]
        
        var current = calendar.startOfDay(for: min)
        let end = calendar.startOfDay(for: max)

        while current <= end {
            if let sr = dateWithTime(from: sunrise, on: current),
               let ss = dateWithTime(from: sunset, on: current) {
                keyDates.append(sr.addingTimeInterval(-sunriseBefore)) // sunriseStart
                keyDates.append(sr)
                keyDates.append(sr.addingTimeInterval(sunriseAfter))  // sunriseEnd
                keyDates.append(ss.addingTimeInterval(-sunsetBefore)) // sunsetStart
                keyDates.append(ss)
                keyDates.append(ss.addingTimeInterval(sunsetAfter))  // sunsetEnd
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        // Filter and sort dates within [min, max]
        let filtered = keyDates.filter { $0 >= min && $0 <= max }.sorted()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current


        let stops = filtered.map { date in
            Gradient.Stop(color: backgroundColor(sunrise: sunrise, sunset: sunset, date: date),
                          location: normalized(date))
        }
        
        print("Filtered key dates:")
        for (index, date) in filtered.enumerated() {
            print("– \(formatter.string(from: date)) \(stops[index].color.description)")
        }

        return LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom)
    }

    func timeToDate(_ timeString: String, reference: Date) -> Date? {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = TimeZone.current
        guard let time = timeFormatter.date(from: timeString) else { return nil }
        var components = calendar.dateComponents([.year, .month, .day], from: reference)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute

        return calendar.date(from: components)
    }
}

extension Color {
    static func lerp(from: Color, to: Color, t: Double) -> Color {
        let fromUIColor = UIColor(from)
        let toUIColor = UIColor(to)

        var fr: CGFloat = 0, fg: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
        var tr: CGFloat = 0, tg: CGFloat = 0, tb: CGFloat = 0, ta: CGFloat = 0

        fromUIColor.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
        toUIColor.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)

        let r = fr + (tr - fr) * CGFloat(t)
        let g = fg + (tg - fg) * CGFloat(t)
        let b = fb + (tb - fb) * CGFloat(t)
        let a = fa + (ta - fa) * CGFloat(t)

        return Color(red: r, green: g, blue: b, opacity: a)
    }
}

//    let sampleLogs: [SleepLog] = (0..<20).map { offset in
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let baseDate = formatter.date(from: "2025-07-10")!
//        let currentDate = Calendar.current.date(byAdding: .day, value: offset, to: baseDate)!
//
//        let dateString = formatter.string(from: currentDate)
//
//        // sleep between 22:00 – 01:30
//        let sleepHour = Int.random(in: 22...25) % 24
//        let sleepMinute = [0, 15, 30, 45].randomElement()!
//
//        // wake between 06:00 – 09:00
//        let wakeHour = Int.random(in: 6...9)
//        let wakeMinute = [0, 15, 30, 45].randomElement()!
//
//        let sleepTime = String(format: "%02d:%02d", sleepHour, sleepMinute)
//        let wakeTime = String(format: "%02d:%02d", wakeHour, wakeMinute)
//
//        let reasons = [
//            (1, "Late movie"),
//            (2, "Work deadline"),
//            (3, "Scrolling phone"),
//            (4, "Insomnia"),
//            (5, "Social event")
//        ]
//        let useReason = Bool.random()
//        let reason = useReason ? reasons.randomElement()! : (nil, nil)
//
//        return SleepLog(
//            documentID: UUID().uuidString,
//            date: dateString,
//            sleepTime: sleepTime,
//            wakeTime: wakeTime,
//            expectedWakeTime: "07:00",
//            reasonId: reason.0,
//            customReason: reason.1,
//            createdAt: Date()
//        )
//    }

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}
