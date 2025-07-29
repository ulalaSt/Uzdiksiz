//
//  Loadable.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 29.07.2025.
//

import Foundation
import SwiftUI

typealias LoadableSubject<Value> = Binding<Loadable<Value>>

enum Loadable<T> {

    case notRequested
    case isLoading(last: T?, cancelBag: CancelBag)
    case loaded(T)
    case failed(APIError)

    var value: T? {
        switch self {
        case let .loaded(value): return value
        case let .isLoading(last: value, cancelBag: _): return value
        default: return nil
        }
    }
    var error: APIError? {
        switch self {
        case let .failed(error): return error
        default: return nil
        }
    }
    var isLoading: Bool {
        switch self {
        case .isLoading(_, _): return true
        default: return false
        }
    }
    var isLoaded: Bool {
        switch self {
        case .loaded(_): return true
        default: return false
        }
    }
}

extension Loadable {
    mutating func setIsLoading(cancelBag: CancelBag) {
        self = .isLoading(last: value, cancelBag: cancelBag)
    }
    
    mutating func cancelLoading() {
        switch self {
        case let .isLoading(last, cancelBag):
            cancelBag.cancel()
            if let last = last {
                self = .loaded(last)
            } else {
                self = .failed(.cancelled)
            }
        default: break
        }
    }
    
    func map<V>(_ transform: (T) throws -> V) -> Loadable<V> {
        do {
            switch self {
            case .notRequested: return .notRequested
            case let .failed(error): return .failed(error)
            case let .isLoading(value, cancelBag):
                return .isLoading(last: try value.map { try transform($0) },
                                  cancelBag: cancelBag)
            case let .loaded(value):
                return .loaded(try transform(value))
            }
        } catch {
            return .failed(.unexpectedError("Could not map"))
        }
    }
}

extension Loadable where T == Empty {
    mutating func setLoaded() {
        self = .loaded(Empty())
    }
}
protocol SomeOptional {
    associatedtype Wrapped
    func unwrap() throws -> Wrapped
}

struct ValueIsMissingError: Error {
    var localizedDescription: String {
        NSLocalizedString("Data is missing", comment: "")
    }
}

extension Optional: SomeOptional {
    func unwrap() throws -> Wrapped {
        switch self {
        case let .some(value): return value
        case .none: throw ValueIsMissingError()
        }
    }
}

extension Loadable where T: SomeOptional {
    func unwrap() -> Loadable<T.Wrapped> {
        map { try $0.unwrap() }
    }
}

extension Loadable: Equatable where T: Equatable {
    static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
        case (.notRequested, .notRequested): return true
        case let (.isLoading(lhsV, lhsC), .isLoading(rhsV, rhsC)):
            return lhsV == rhsV && lhsC === rhsC
        case let (.loaded(lhsV), .loaded(rhsV)): return lhsV == rhsV
        case let (.failed(lhsE), .failed(rhsE)):
            return lhsE == rhsE
        default: return false
        }
    }
}
extension Loadable: Hashable where T: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

struct Empty: Equatable { }

extension Loadable where T == Void {
    func mapToEmpty() -> Loadable<Empty> {
        map { Empty() }
    }
}
