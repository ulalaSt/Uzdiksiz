//
//  AuthViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//

import FirebaseAuth
import Combine
import GoogleSignIn
import FirebaseCore

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
    
    func signInWithGoogle(presenting: UIViewController) {
        isLoading = true

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.errorMessage = "Missing Google client ID."
            self.isLoading = false
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                return
            }

            guard let result = result else {
                self.errorMessage = "Google Sign-In failed."
                self.isLoading = false
                return
            }

            let user = result.user
            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString

            guard let idToken = idToken else {
                self.errorMessage = "Failed to retrieve ID token."
                self.isLoading = false
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.user = authResult?.user
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "No user found."
            return
        }

        user.delete { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.user = nil
            }
        }
    }
}
