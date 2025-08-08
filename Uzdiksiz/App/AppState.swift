//
//  AppState.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 04.08.2025.
//

import Combine

final class AppState: ObservableObject {
    init(user: Loadable<AppUser>) {
        self.user = user
    }
    @Published var user: Loadable<AppUser>
}
