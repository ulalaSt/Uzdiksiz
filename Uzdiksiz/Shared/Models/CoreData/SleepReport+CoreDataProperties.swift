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
    /// Sleep quality score for the day (0–100)
    func quality(targetStart: Time, targetEnd: Time) -> Int {
        guard let sessions = sessions as? Set<SleepSession>, !sessions.isEmpty else {
            return 0
        }
        
        // Convert sessions into intervals in minutes
        let intervals: [(start: Int, end: Int)] = sessions.compactMap { s in
            let start = Int(s.startHour * 60 + s.startMinute)
            let end   = Int(s.endHour * 60 + s.endMinute)
            
            if start < end {
                // same-day sleep
                return (start, end)
            } else if start > end {
                // crossed midnight → normalize by adding 24h to end
                return (start, end + 24 * 60)
            } else {
                return nil
            }
        }

        let totalSleep = intervals.reduce(0) { $0 + ($1.end - $1.start) }
        
        let targetStartMinutes = targetStart.totalMinutes
        let targetEndMinutes   = targetEnd.totalMinutes
        let targetDuration     = targetEndMinutes - targetStartMinutes
        
        // --- 1. Duration score ---
        let durationScore: Double
        if totalSleep >= targetDuration {
            durationScore = 1.0
        } else {
            durationScore = Double(totalSleep) / Double(targetDuration)
        }
        
        // --- 2. Alignment score ---
        // Check midpoint of actual sleep vs midpoint of target window
        let actualMid = intervals.reduce(0) { $0 + ($1.start + $1.end) / 2 } / intervals.count
        let targetMid = (targetStartMinutes + targetEndMinutes) / 2
        
        let diff = abs(actualMid - targetMid)
        // If midpoint is within 30 min → full score, degrade linearly until 3h
        let alignmentScore = max(0, 1.0 - Double(diff) / (180.0))
        
        // --- 3. Fragmentation penalty ---
        // Each extra session reduces score a bit
        let fragmentationPenalty = max(0.7, 1.0 - Double(intervals.count - 1) * 0.15)
        
        // Final score
        let rawScore = (0.6 * durationScore + 0.3 * alignmentScore) * fragmentationPenalty
        return Int((rawScore * 100).rounded())
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
        return sessions.compactMap { s in
            let start = Time(hour: Int(s.startHour), minute: Int(s.startMinute))
            let end   = Time(hour: Int(s.endHour), minute: Int(s.endMinute))
            return start.totalMinutes < end.totalMinutes ? (start, end) : nil
        }
        .sorted { $0.start.totalMinutes < $1.start.totalMinutes }
    }

    /// Total sleep duration (minutes)
    var totalSleepMinutes: Int {
        intervals.reduce(0) { $0 + ($1.end.totalMinutes - $1.start.totalMinutes) }
    }

    /// Total sleep hours + minutes tuple
    var totalSleepHM: (hours: Int, minutes: Int) {
        let h = totalSleepMinutes / 60
        let m = totalSleepMinutes % 60
        return (h, m)
    }

    /// Formatted string for intervals (first main session, others as "+ ...")
    var intervalStrings: [String] {
        intervals.enumerated().map { index, interval in
            let text = "\(interval.start.toString())-\(interval.end.toString())"
            return index == 0 ? text : "+ " + text
        }
    }
}
