//
//  AppUser.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 04.08.2025.
//
import FirebaseAuth

struct AppUser: Equatable, Identifiable {
    let id: String
    let email: String?
    let nickname: String?
}

extension AppUser {
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email
        self.nickname = firebaseUser.displayName
    }
}
