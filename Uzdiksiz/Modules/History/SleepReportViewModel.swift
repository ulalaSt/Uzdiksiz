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
    
    func wakeUp() async throws {
        if let sleepDate = AppState.shared.todaySleptDate {
            let wakeDate = Date()
            let calendar = Calendar.current
            
            // Формируем ключ даты (например: 20250902)
            let components = calendar.dateComponents([.year, .month, .day], from: wakeDate)
            let dateKey = Int32(components.year! * 10000 + components.month! * 100 + components.day!)
            
            // Преобразуем sleepDate и wakeDate в Time
            let sleepHour = calendar.component(.hour, from: sleepDate)
            let sleepMinute = calendar.component(.minute, from: sleepDate)
            let startTime = Time(hour: sleepHour, minute: sleepMinute)
            
            let wakeHour = calendar.component(.hour, from: wakeDate)
            let wakeMinute = calendar.component(.minute, from: wakeDate)
            let endTime = Time(hour: wakeHour, minute: wakeMinute)
            
            // Сохраняем сессию сна (асинхронно)
            try await SleepSessionDbService.shared.createSleepSession(
                dateKey: dateKey,
                startTime: startTime,
                endTime: endTime
            )
        }
        DispatchQueue.main.async {
            AppState.shared.todaySleptDate = nil
        }
    }
}
