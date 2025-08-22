//
//  SleepingViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 22.08.2025.
//

import Combine

final class SleepingViewModel: ObservableObject {
    @Published private(set) var wakeTime: Time
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.wakeTime = AppState.shared.wakeTime
        
        AppState.shared.$wakeTime
            .removeDuplicates()
            .assign(to: &$wakeTime)
    }
    
    func updateWakeTime(_ time: Time) {
        AppState.shared.wakeTime = time   // push to source of truth
    }
    
    func wakeUp() {
        AppState.shared.todaySleptDate = nil
    }
}
