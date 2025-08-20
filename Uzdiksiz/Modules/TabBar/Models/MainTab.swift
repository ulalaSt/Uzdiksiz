//
//  MainTab.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 07.08.2025.
//

enum MainTab: Int {
    case home
    case history
    case profile

    var iconTitle: String {
        switch self {
        case .home:
            return "house.fill"
        case .history:
            return "chart.pie"
        case .profile:
            return "person.fill"
        }
    }

    var title: String {
        switch self {
        case .home:
            return "Бас бет"
        case .history:
            return "Статистика"
        case .profile:
            return "Профиль"
        }
    }
}
