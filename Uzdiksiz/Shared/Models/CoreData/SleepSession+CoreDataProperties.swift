//
//  SleepSession+CoreDataProperties.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 24.08.2025.
//

import Foundation
import CoreData


extension SleepSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepSession> {
        return NSFetchRequest<SleepSession>(entityName: "SleepSession")
    }

    @NSManaged public var startHour: Int32
    @NSManaged public var startMinute: Int32
    @NSManaged public var endHour: Int32
    @NSManaged public var endMinute: Int32
    @NSManaged public var report: SleepReport?

}

extension SleepSession: Identifiable {
    public var id: NSManagedObjectID { objectID }
}

extension SleepSession {
    var startTime: Time {
        Time(hour: Int(startHour), minute: Int(startMinute))
    }
    
    var endTime: Time {
        Time(hour: Int(endHour), minute: Int(endMinute))
    }
    
    var intervalString: String {
        "\(startTime.toString())-\(endTime.toString())"
    }
    
    var minutesDuration: Int {
        let s = startTime.totalMinutes
        var e = endTime.totalMinutes
        if e < s { e += 24 * 60 }
        return e - s
    }
}
