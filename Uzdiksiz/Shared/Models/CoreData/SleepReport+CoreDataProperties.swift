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
