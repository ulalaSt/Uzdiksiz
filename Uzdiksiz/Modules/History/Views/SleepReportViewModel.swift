//
//  SleepReportViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 30.08.2025.
//

import Combine
import Foundation
import SwiftUI
import CoreData

class SleepReportViewModel: ObservableObject {
    @Published var sleepReports: Loadable<[SleepReport]> = .notRequested
    let cancelBag = CancelBag()
    
    init() {
        sleepReports = .isLoading(last: nil, cancelBag: CancelBag())
        
        SleepSessionDbService.shared.reports()
            .map(Loadable.loaded)
            .receive(on: DispatchQueue.main)
            .assign(to: &$sleepReports)
    }
    
    // MARK: - Create
    @MainActor
    func createSleepSession(
        dateKey: Int32,
        startTime: Time,
        endTime: Time,
        state: Binding<Loadable<SleepSession>>
    ) async {
        state.wrappedValue = .isLoading(last: nil, cancelBag: CancelBag())
        do {
            let session = try await SleepSessionDbService.shared.createSleepSession(
                dateKey: dateKey,
                startTime: startTime,
                endTime: endTime
            )
            state.wrappedValue = .loaded(session)
        } catch {
            state.wrappedValue = .failed(.unexpectedError(error.localizedDescription))
        }
    }
    
    // MARK: - Delete
    func deleteSession(
        sessionID: NSManagedObjectID,
        state: Binding<Loadable<Void>>
    ) async {
        state.wrappedValue = .isLoading(last: nil, cancelBag: CancelBag())
        do {
            try await SleepSessionDbService.shared.deleteSleepSession(sessionID: sessionID)
            state.wrappedValue = .loaded(())
        } catch {
            state.wrappedValue = .failed(.unexpectedError(error.localizedDescription))
        }
    }
}
