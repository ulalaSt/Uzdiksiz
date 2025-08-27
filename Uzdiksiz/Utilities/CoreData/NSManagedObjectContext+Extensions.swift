//
//  NSManagedObjectContext+Extensions.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 24.08.2025.
//

import Foundation
import CoreData

public extension NSManagedObjectContext {
    /// Save a context, or handle the save error (for example, when there data inconsistency or low memory).
    func save(with context: String) throws {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            print("Error saving context '\(context)'")
            throw error
        }
    }

    func perform<T>(_ operation: @Sendable @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            perform {
                do {
                    let result = try operation(self)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
