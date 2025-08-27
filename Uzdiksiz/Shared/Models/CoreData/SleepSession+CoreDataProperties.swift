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
