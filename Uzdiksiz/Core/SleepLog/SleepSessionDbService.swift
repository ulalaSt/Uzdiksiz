//
//  SleepLogDbService.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 24.08.2025.
//

import Foundation
import CoreData
import Combine

enum SleepSessionError: Error {
    case overlappingSession(withSession: SleepSession)
    case sessionNotFound
}

class SleepSessionDbService {
    static private let dbName = "SleepDataStore"
    private let persistentContainer: NSPersistentCloudKitContainer
    private let context: NSManagedObjectContext
    static public let shared = SleepSessionDbService()
    
    public init() {
        let modelURL = Bundle.main.url(forResource: SleepSessionDbService.dbName, withExtension: "momd")!
        persistentContainer = NSPersistentCloudKitContainer(
            name: SleepSessionDbService.dbName,
            managedObjectModel: NSManagedObjectModel(contentsOf: modelURL)!
        )
        let description = persistentContainer.persistentStoreDescriptions.first!
        description.cloudKitContainerOptions =
            NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.kz.uzdiksiz.Uzdiksiz")
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true

        // Enable history & notifications for sync
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        context = persistentContainer.newBackgroundContext()
    }
    
    private func normalizeInterval(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int) -> (Int, Int) {
        var start = startHour * 60 + startMinute
        let end = endHour * 60 + endMinute

        if end <= start {
            start -= 24 * 60 // push start into "yesterday"
        }

        return (start, end)
    }

    private func checkForOverlap(in report: SleepReport, sessionID: NSManagedObjectID? = nil, newStart: Int, newEnd: Int, excluding session: SleepSession? = nil) throws {
        if let existingSessions = report.sessions as? Set<SleepSession> {
            for s in existingSessions where s != session {
                if sessionID == s.id {
                    continue
                }
                let (existingStart, existingEnd) = normalizeInterval(
                    startHour: Int(s.startHour),
                    startMinute: Int(s.startMinute),
                    endHour: Int(s.endHour),
                    endMinute: Int(s.endMinute)
                )

                if newStart < existingEnd && newEnd > existingStart {
                    throw SleepSessionError.overlappingSession(withSession: s)
                }
            }
        }
    }

    // MARK: - Tag Management
    
    // Create Tag
    @discardableResult
    func createSleepSession(
        dateKey: Int32,
        startTime: Time,
        endTime: Time
    ) async throws -> SleepSession {
        try await context.perform { context in
            // Fetch or create the SleepReport
            let request: NSFetchRequest<SleepReport> = SleepReport.fetchRequest()
            request.predicate = NSPredicate(format: "dateKey == %d", dateKey)
            request.fetchLimit = 1
            
            let report: SleepReport
            if let existing = try context.fetch(request).first {
                report = existing
            } else {
                report = SleepReport(context: context)
                report.dateKey = dateKey
                report.targetStartHour = Int32(AppState.shared.sleepTime.hour)
                report.targetStartMinute = Int32(AppState.shared.sleepTime.minute)
                report.targetEndHour = Int32(AppState.shared.wakeTime.hour)
                report.targetEndMinute = Int32(AppState.shared.wakeTime.minute)
            }
            
            let (newStart, newEnd) = self.normalizeInterval(
                startHour: startTime.hour,
                startMinute: startTime.minute,
                endHour: endTime.hour,
                endMinute: endTime.minute
            )

            try self.checkForOverlap(in: report, newStart: newStart, newEnd: newEnd)

            // Create new SleepSession
            let session = SleepSession(context: context)
            session.startHour = Int32(startTime.hour)
            session.startMinute = Int32(startTime.minute)
            session.endHour = Int32(endTime.hour)
            session.endMinute = Int32(endTime.minute)
            
            // Link session to report
            session.report = report
            report.addToSessions(session)
            
            try context.save(with: "createSleepSession")
            return session
        }
    }

    func updateSleepSession(
        sessionID: NSManagedObjectID,
        newStartTime: Time,
        newEndTime: Time
    ) async throws -> SleepSession {
        try await context.perform { context in
            // Fetch the session by ID
            guard let session = try context.existingObject(with: sessionID) as? SleepSession else {
                throw SleepSessionError.sessionNotFound
            }
            
            guard let report = session.report else {
                throw SleepSessionError.sessionNotFound
            }
            
            let (newStart, newEnd) = self.normalizeInterval(
                startHour: newStartTime.hour,
                startMinute: newStartTime.minute,
                endHour: newEndTime.hour,
                endMinute: newEndTime.minute
            )

            try self.checkForOverlap(in: report, sessionID: sessionID, newStart: newStart, newEnd: newEnd)

            // Update session times
            session.startHour = Int32(newStartTime.hour)
            session.startMinute = Int32(newStartTime.minute)
            session.endHour = Int32(newEndTime.hour)
            session.endMinute = Int32(newEndTime.minute)
            
            // Save changes
            try context.save(with: "updateSleepSession")
            
            return session
        }
    }

    func deleteSleepSession(sessionID: NSManagedObjectID) async throws {
        try await context.perform { context in
            guard let session = try? context.existingObject(with: sessionID) as? SleepSession else {
                throw SleepSessionError.sessionNotFound
            }
            let report = session.report
            var isLastSession: Bool = false
            if let count = report?.sessions?.count, count == 1 {
                isLastSession = true
            }
            context.delete(session)
            if let report, isLastSession {
                context.delete(report)
            }
            
            try context.save(with: "deleteSleepSession")
        }
    }
    
    func deleteSleepReport(reportID: NSManagedObjectID) async throws {
        try await context.perform { context in
            guard let report = try? context.existingObject(with: reportID) as? SleepReport else {
                throw SleepSessionError.sessionNotFound
            }
            if let sessions = report.sessions as? Set<SleepSession> {
                for session in sessions {
                    context.delete(session)
                }
            }
            context.delete(report)
            
            try context.save(with: "deleteSleepReport")
        }
    }
    
    public func fetchReports() async throws -> [SleepReport] {
        try await context.perform { context in
            let request: NSFetchRequest<SleepReport> = SleepReport.fetchRequest()
            return try context.fetch(request)
        }
    }
    
    public func reports() -> AnyPublisher<[SleepReport], Never> {
        let request = SleepReport.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(SleepReport.dateKey), ascending: true)]
        return CoreDataPublisher(request: request, context: context)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func report(for dateKey: Int32) -> AnyPublisher<SleepReport?, Never> {
        let request = SleepReport.fetchRequest()
        request.predicate = NSPredicate(format: "dateKey == %d", dateKey)
        request.fetchLimit = 1
        
        return CoreDataPublisher(request: request, context: context)
            .map { $0.first } // convert to optional (one report)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func reports(from startDateKey: Int32, to endDateKey: Int32) -> AnyPublisher<[SleepReport], Never> {
        let request = SleepReport.fetchRequest()
        request.predicate = NSPredicate(format: "dateKey >= %d AND dateKey <= %d", startDateKey, endDateKey)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(SleepReport.dateKey), ascending: true)]
        
        return CoreDataPublisher(request: request, context: context)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func deleteAllReports() async throws {
        let fetchRequest: NSFetchRequest<SleepReport> = SleepReport.fetchRequest()
        let reports = try context.fetch(fetchRequest)

        for report in reports {
            try await deleteSleepReport(reportID: report.objectID)
        }
    }
}


// MARK: - Publishers for SleepSession
extension SleepSessionDbService {
    
    /// Publishes all sessions (use carefully, may be a lot of data)
    public func sessions() -> AnyPublisher<[SleepSession], Never> {
        let request = SleepSession.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(SleepSession.startHour), ascending: true),
            NSSortDescriptor(key: #keyPath(SleepSession.startMinute), ascending: true)
        ]
        
        return CoreDataPublisher(request: request, context: context)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Publishes all sessions for a given report
    public func sessions(for reportID: NSManagedObjectID) -> AnyPublisher<[SleepSession], Never> {
        guard let report = try? context.existingObject(with: reportID) as? SleepReport else {
            return Just([]).eraseToAnyPublisher()
        }
        
        let request = SleepSession.fetchRequest()
        request.predicate = NSPredicate(format: "report == %@", report)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(SleepSession.startHour), ascending: true),
            NSSortDescriptor(key: #keyPath(SleepSession.startMinute), ascending: true)
        ]
        
        return CoreDataPublisher(request: request, context: context)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Publishes sessions for a given dateKey
    public func sessions(for dateKey: Int32) -> AnyPublisher<[SleepSession], Never> {
        let request = SleepSession.fetchRequest()
        request.predicate = NSPredicate(format: "report.dateKey == %d", dateKey)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(SleepSession.startHour), ascending: true),
            NSSortDescriptor(key: #keyPath(SleepSession.startMinute), ascending: true)
        ]
        
        return CoreDataPublisher(request: request, context: context)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Publishes a single session
    public func session(for id: NSManagedObjectID) -> AnyPublisher<SleepSession?, Never> {
        let request = SleepSession.fetchRequest()
        request.predicate = NSPredicate(format: "SELF == %@", id)
        request.fetchLimit = 1
        
        return CoreDataPublisher(request: request, context: context)
            .map { $0.first }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
