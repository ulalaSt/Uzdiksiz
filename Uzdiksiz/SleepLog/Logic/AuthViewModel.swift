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
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var user: Loadable<User?> = .notRequested
    private var cancelBag = CancelBag()
    private var db = Firestore.firestore()

    init() {
        user.setIsLoading(cancelBag: cancelBag)
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = .loaded(user)
        }
    }

    func signIn(email: String, password: String) {
        user.setIsLoading(cancelBag: cancelBag)
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.user = .failed(.unexpectedError(error.localizedDescription))
            } else {
                self?.user = .loaded(result?.user)
            }
        }
    }

    func signUp(email: String, password: String) {
        user.setIsLoading(cancelBag: cancelBag)
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.user = .failed(.unexpectedError(error.localizedDescription))
            } else {
                self?.user = .loaded(result?.user)
            }
        }
    }
    
    func signInWithGoogle(presenting: UIViewController) {
        user.setIsLoading(cancelBag: cancelBag)
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            user = .failed(.clientError("Missing Google client ID."))
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                user = .failed(.clientError(error.localizedDescription))
                return
            }

            guard let result = result else {
                user = .failed(.clientError("Google Sign-In failed."))
                return
            }

            let user = result.user
            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString

            guard let idToken = idToken else {
                self.user = .failed(.clientError("Failed to retrieve ID token."))
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.user = .failed(.clientError(error.localizedDescription))
                } else {
                    self.user = .loaded(authResult?.user)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = .loaded(nil)
        } catch {
            self.user = .failed(.unexpectedError(error.localizedDescription))
        }
    }

    func deleteAccount() {
        user.setIsLoading(cancelBag: cancelBag)
        guard let user = Auth.auth().currentUser else {
            self.user = .failed(.unexpectedError("No user found."))
            return
        }

        let uid = user.uid
        
        // 1. Удаляем связанные данные из Firestore
        db.collection("users").document(uid).delete { error in
            if let error = error {
                self.user = .failed(.unexpectedError("Failed to delete user data: \(error.localizedDescription)"))
                return
            }

            // 2. Теперь удаляем аккаунт из Firebase Auth
            user.delete { error in
                if let error = error {
                    self.user = .failed(.unexpectedError("Failed to delete account: \(error.localizedDescription)"))
                } else {
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        print("Sign-out failed: \(error.localizedDescription)")
                    }
                    self.user = .loaded(nil)
                }
            }
        }
    }
}
