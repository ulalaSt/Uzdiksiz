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
    case overlappingSession
    case sessionNotFound
}

class SleepSessionDbService {
    static private let dbName = "SleepDataStore"
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    static public let shared = SleepSessionDbService()
    
    public init() {
        let modelURL = Bundle.main.url(forResource: SleepSessionDbService.dbName, withExtension: "momd")!
        persistentContainer = NSPersistentContainer(
            name: SleepSessionDbService.dbName,
            managedObjectModel: NSManagedObjectModel(
                contentsOf: modelURL)!)
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        context = persistentContainer.newBackgroundContext()
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
            }
            
            // Convert Time to "minutes since midnight"
            let newStart = startTime.hour * 60 + startTime.minute
            let newEnd = endTime.hour * 60 + endTime.minute
            
            // Check for overlap
            if let existingSessions = report.sessions as? Set<SleepSession> {
                for s in existingSessions {
                    let existingStart = Int(s.startHour) * 60 + Int(s.startMinute)
                    let existingEnd = Int(s.endHour) * 60 + Int(s.endMinute)
                    
                    if newStart < existingEnd && newEnd > existingStart {
                        throw SleepSessionError.overlappingSession
                    }
                }
            }
            
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
            
            // Convert new times to minutes since midnight
            let newStart = newStartTime.hour * 60 + newStartTime.minute
            let newEnd   = newEndTime.hour * 60 + newEndTime.minute
            
            // Check overlap against other sessions in the same report
            if let existingSessions = report.sessions as? Set<SleepSession> {
                for s in existingSessions where s != session {
                    let existingStart = Int(s.startHour) * 60 + Int(s.startMinute)
                    let existingEnd   = Int(s.endHour) * 60 + Int(s.endMinute)
                    
                    if newStart < existingEnd && newEnd > existingStart {
                        throw SleepSessionError.overlappingSession
                    }
                }
            }
            
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
            
            // Get parent report before deletion
            let report = session.report
            
            // Delete the session
            context.delete(session)
            
            // If the report is now empty, delete it too
            if let report,
               let sessions = report.sessions as? Set<SleepSession>,
               sessions.isEmpty {
                context.delete(report)
            }
            
            try context.save(with: "deleteSleepSession")
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
}

