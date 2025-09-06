//
//  SleepReport+CoreDataProperties.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 24.08.2025.
//

import Foundation
import CoreData


extension SleepReport {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepReport> {
        return NSFetchRequest<SleepReport>(entityName: "SleepReport")
    }

    @NSManaged public var dateKey: Int32
    @NSManaged public var sessions: NSSet?
    
    
    @NSManaged public var targetStartHour: Int32
    @NSManaged public var targetStartMinute: Int32
    @NSManaged public var targetEndHour: Int32
    @NSManaged public var targetEndMinute: Int32
}

// MARK: Generated accessors for sessions
extension SleepReport {

    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: SleepSession)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: SleepSession)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)

}

extension SleepReport: Identifiable {
    public var id: NSManagedObjectID { objectID }
}

extension SleepReport {
    var targetStart: Time {
        Time(hour: Int(targetStartHour), minute: Int(targetStartMinute))
    }
    
    var targetEnd: Time {
        Time(hour: Int(targetEndHour), minute: Int(targetEndMinute))
    }
    
    var date: Date {
        let key = Int(dateKey)
        let year  = key / 10_000
        let month = (key / 100) % 100
        let day   = key % 100
        
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        
        return Calendar.current.date(from: comps) ?? Date()
    }
    
    /// Sessions as sorted intervals of Time
    var intervals: [(start: Time, end: Time)] {
        guard let sessions = sessions as? Set<SleepSession> else { return [] }
        return sessions.map { s in
            let start = Time(hour: Int(s.startHour), minute: Int(s.startMinute))
            let end   = Time(hour: Int(s.endHour), minute: Int(s.endMinute))
            return (start, end)
        }
        .sorted { $0.end.totalMinutes < $1.end.totalMinutes }
    }

    /// Total sleep duration (minutes)
    var totalSleepMinutes: Int {
        intervals.reduce(0) { total, interval in
            let start = interval.start.totalMinutes
            let end   = interval.end.totalMinutes
            let duration = end >= start
                ? (end - start)
                : (end + 24 * 60 - start) // crossed midnight
            return total + duration
        }
    }

    /// Total sleep hours + minutes tuple
    var totalSleepHM: (hours: Int, minutes: Int) {
        let h = totalSleepMinutes / 60
        let m = totalSleepMinutes % 60
        return (h, m)
    }

    public override var debugDescription: String {
        var result = "📊 SleepReport for \(date.formatted(date: .abbreviated, time: .omitted))\n"
        
        if let sessions = sessions as? Set<SleepSession>, !sessions.isEmpty {
            for (i, s) in sessions.sorted(by: {
                ($0.startHour, $0.startMinute) < ($1.startHour, $1.startMinute)
            }).enumerated() {
                let start = String(format: "%02d:%02d", s.startHour, s.startMinute)
                let end   = String(format: "%02d:%02d", s.endHour, s.endMinute)
                result += "   #\(i+1) 🛌 \(start) – \(end)\n"
            }
        } else {
            result += "   ⛔️ No sessions\n"
        }
        return result
    }

}

extension SleepReport {
    
    func quality() -> Int {
        let durationScore = scoreDuration()
        let sleepTimeScore = scoreSleepTime()
        let wakeTimeScore = scoreWakeTime()
        let fragmentationScore = scoreFragmentation()
        
        // Weights
        let totalScore =
            0.4 * Double(durationScore) +
            0.25 * Double(sleepTimeScore) +
            0.25 * Double(wakeTimeScore) +
            0.1 * Double(fragmentationScore)
        
        return Int(totalScore.rounded())
    }
    
    // MARK: - Duration
    private func scoreDuration() -> Int {
        let targetDuration = minutesBetween(start: targetStart, end: targetEnd)
        let minDuration = Double(targetDuration) * 0.9
        let maxDuration = Double(targetDuration) * 1.1
        let actual = Double(totalSleepMinutes)
        
        if actual >= minDuration && actual <= maxDuration {
            return 100
        }
        
        // Penalty grows the further from range
        if actual < minDuration {
            return Int(max(0, 100 * (actual / minDuration)))
        } else {
            return Int(max(0, 100 * ((2 * maxDuration - actual) / maxDuration)))
        }
    }
    
    // MARK: - Sleep Time
    private func scoreSleepTime() -> Int {
        guard let first = intervals.min(by: { $0.start.totalMinutes < $1.start.totalMinutes }) else {
            return 0
        }
        let bedtime = first.start.totalMinutes
        let targetStartMinutes = targetStart.totalMinutes
        let targetDuration = minutesBetween(start: targetStart, end: targetEnd)
        
        let latestAllowed = targetStartMinutes + Int(Double(targetDuration) * 0.05) // +5%
        
        if bedtime <= latestAllowed {
            return 100
        }
        
        // Deduct 1 point per minute late (can tune)
        let penalty = bedtime - latestAllowed
        return max(0, 100 - penalty)
    }
    
    // MARK: - Wake Time
    private func scoreWakeTime() -> Int {
        let mainSessions = intervals.filter { minutesBetween(start: $0.start, end: $0.end) >= 30 }
        guard let main = mainSessions.max(by: { $0.end.totalMinutes < $1.end.totalMinutes }) else {
            return 0
        }
        
        // Wake time = end of main sleep
        var wake = main.end.totalMinutes
        let targetEndMinutes = targetEnd.totalMinutes
        let targetDuration = minutesBetween(start: targetStart, end: targetEnd)
        
        let earliestAllowed = targetEndMinutes - Int(Double(targetDuration) * 0.10) // -10%
        let latestAllowed   = targetEndMinutes + Int(Double(targetDuration) * 0.05) // +5%
        
        if wake >= earliestAllowed && wake <= latestAllowed {
            return 100
        }
        
        if wake < earliestAllowed {
            // Too early: proportional penalty
            let diff = earliestAllowed - wake
            return max(0, 100 - diff)
        } else {
            // Too late: proportional penalty
            let diff = wake - latestAllowed
            return max(0, 100 - diff)
        }
    }
    
    // MARK: - Fragmentation
    private func scoreFragmentation() -> Int {
        let sessions = intervals
        guard !sessions.isEmpty else { return 0 }
        
        var mainBlocks = 0
        var naps = 0
        
        for s in sessions {
            let duration = minutesBetween(start: s.start, end: s.end)
            if duration >= 30 {
                mainBlocks += 1
            } else {
                naps += 1
            }
        }
        
        if mainBlocks == 1 && naps <= 1 {
            return 100
        }
        
        // Penalty: -20 points for each extra block beyond allowed
        let extra = max(0, (mainBlocks - 1) + max(0, naps - 1))
        return max(0, 100 - extra * 20)
    }
    
    // MARK: - Helpers
    private func minutesBetween(start: Time, end: Time) -> Int {
        let s = start.totalMinutes
        var e = end.totalMinutes
        if e < s { e += 24 * 60 }
        return e - s
    }
}
