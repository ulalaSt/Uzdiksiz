//
//  MainTab.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 07.08.2025.
//

enum MainTab: Int, CaseIterable {
    case home
    case history
    case goal
    case profile

    var iconTitle: String {
        switch self {
        case .home:
            return "house.fill"
        case .history:
            return "chart.pie"
        case .goal:
            return "target"
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
        case .goal:
            return "Мақсат"
        case .profile:
            return "Профиль"
        }
    }
}
