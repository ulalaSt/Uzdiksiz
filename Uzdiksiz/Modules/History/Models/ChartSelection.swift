//
//  ChartSelection.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 10.09.2025.
//
import Foundation

struct ChartSelection<X: Hashable, Y: Hashable> {
    var isSameX: (X, X) -> Bool
}

extension ChartSelection where X: Equatable {
    static var exact: ChartSelection {
        .init(isSameX: { $0 == $1 })
    }
}

extension ChartSelection where X == Date {
    static var sameDay: ChartSelection {
        .init(isSameX: { lhs, rhs in
            Calendar.current.isDate(lhs, inSameDayAs: rhs)
        })
    }
}

