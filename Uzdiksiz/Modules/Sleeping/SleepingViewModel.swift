//
//  SleepingViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 22.08.2025.
//

import Combine
import Foundation

final class SleepingViewModel: ObservableObject {
    @Published private(set) var wakeTime: Time
    let logService: SleepLogViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(logService: SleepLogViewModel) {
        self.wakeTime = AppState.shared.wakeTime
        self.logService = logService
        AppState.shared.$wakeTime
            .removeDuplicates()
            .assign(to: &$wakeTime)
    }
    
    func updateWakeTime(_ time: Time) {
        AppState.shared.wakeTime = time   // push to source of truth
    }
    
    func wakeUp() {
        if let sleepDate = AppState.shared.todaySleptDate {
            logService.saveSleepLog(wakeTime: Date(), sleepTime: sleepDate, reasonId: nil, customReason: nil)
        }
        AppState.shared.todaySleptDate = nil
    }
}
