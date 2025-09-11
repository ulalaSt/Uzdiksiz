//
//  SleepSettingsState.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 20.08.2025.
//

enum SleepSettingsState: Int, CaseIterable, Identifiable {
    var id: Self { self }
    case sleep
    case wake
    
    var title: String {
        switch self {
        case .sleep:
            "Ұйқы"
        case .wake:
            "Оятқыш"
        }
    }
}
