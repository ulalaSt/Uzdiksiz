//
//  AuthViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//

import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var isLoading = true

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            self.isLoading = false
        }
    }

    func signIn(email: String, password: String) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.user = result?.user
            }
        }
    }

    func signUp(email: String, password: String) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.user = result?.user
            }
        }
    }
}
