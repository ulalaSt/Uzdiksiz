//
//  FirebaseAuthService.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 04.08.2025.
//
import Combine
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices
import FirebaseCore

class FirebaseAuthService: AuthService {
    private let currentUser: CurrentValueSubject<Loadable<AppUser>, Never>
    var user: Loadable<AppUser> { currentUser.value }
    var userPublisher: AnyPublisher<Loadable<AppUser>, Never> {
        return currentUser.removeDuplicates().eraseToAnyPublisher()
    }

    private var handle: AuthStateDidChangeListenerHandle?
    let cancelBag = CancelBag()
    init() {
        if let user = Auth.auth().currentUser {
            currentUser = .init(.loaded(AppUser(firebaseUser: user)))
        } else {
            currentUser = .init(.failed(.notRegistered))
        }

        Auth.auth().languageCode = "ru"
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user {
                self?.currentUser.send(.loaded(AppUser(firebaseUser: user)))
            } else {
                self?.currentUser.send(.failed(.notRegistered))
            }
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    
    func signUp(email: String, password: String, nickname: String) {
        currentUser.value.setIsLoading(cancelBag: cancelBag)
        switch validateUsername(nickname) {
        case .failure(let validationError):
            currentUser.send(.failed(.clientError(validationError.rawValue)))
        case .success:
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                if let error = error {
                    self?.currentUser.send(.failed(.unexpectedError(error.localizedDescription)))
                    return
                }

                guard let firebaseUser = result?.user else {
                    self?.currentUser.send(.failed(.unexpectedError("Пайдаланушы регистрациясы сәтсіз аяқталды")))
                    return
                }
                let changeRequest = firebaseUser.createProfileChangeRequest()
                changeRequest.displayName = nickname
                changeRequest.commitChanges { error in
                    if let error = error {
                        firebaseUser.delete { deleteError in
                            if let deleteError = deleteError {
                                self?.currentUser.send(.failed(.unexpectedError("Failed to set nickname and failed to delete user: \(deleteError.localizedDescription)")))
                            } else {
                                self?.currentUser.send(.failed(.unexpectedError("Failed to set nickname. User creation rolled back.")))
                            }
                        }
                        return
                    }
                }
            }
        }
    }

    func signIn(email: String, password: String) {
        currentUser.value.setIsLoading(cancelBag: cancelBag)
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.currentUser.send(.failed(.unexpectedError(error.localizedDescription)))
            } else if let user = result?.user {
                self?.currentUser.send(.loaded(AppUser(firebaseUser: user)))
            } else {
                self?.currentUser.send(.failed(.unexpectedError("Unknown sign-in error")))
            }
        }
    }
    
    func getGoogleConfig() -> GIDConfiguration? {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            currentUser.send(.failed(.clientError("Missing Google client ID.")))
            return nil
        }
        return GIDConfiguration(clientID: clientID)
    }
    
    func signInWithGoogle(result: GIDSignInResult?, error: Error?) {
        currentUser.value.setIsLoading(cancelBag: cancelBag)
        
        if let error = error {
            currentUser.send(.failed(.clientError(error.localizedDescription)))
            return
        }

        guard let result = result else {
            currentUser.send(.failed(.clientError("Google Sign-In failed.")))
            return
        }

        let user = result.user
        let idToken = user.idToken?.tokenString
        let accessToken = user.accessToken.tokenString

        guard let idToken = idToken else {
            currentUser.send(.failed(.clientError("Failed to retrieve ID token.")))
            return
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )

        Auth.auth().signIn(with: credential) { [weak self] result, error in
            if let error = error {
                self?.currentUser.send(.failed(.unexpectedError(error.localizedDescription)))
            } else if let user = result?.user {
                self?.currentUser.send(.loaded(AppUser(firebaseUser: user)))
            } else {
                self?.currentUser.send(.failed(.unexpectedError("Unknown sign-in error")))
            }
        }
    }

    func signInWithApple(authorization: ASAuthorization, nonce: String) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = appleIDCredential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8) else {
            currentUser.send(.failed(.clientError("Apple авторизация сәтсіз аяқталды.")))
            return
        }

        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            if let error = error {
                self?.currentUser.send(.failed(.unexpectedError(error.localizedDescription)))
            } else if let user = result?.user {
                self?.currentUser.send(.loaded(AppUser(firebaseUser: user)))
            } else {
                self?.currentUser.send(.failed(.unexpectedError("Unknown sign-in error")))
            }
        }
    }

    func signOut() -> AnyPublisher<Void, APIError> {
        do {
            try Auth.auth().signOut()
            return Just(())
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: APIError.unexpectedError(error.localizedDescription))
                .eraseToAnyPublisher()
        }
    }

    func deleteAccount() -> AnyPublisher<Void, APIError> {
        guard let user = Auth.auth().currentUser else {
            return Fail(error: APIError.unexpectedError("No user found."))
                .eraseToAnyPublisher()
        }

        let uid = user.uid

        return Future<Void, APIError> { promise in
            Firestore.firestore().collection("users").document(uid).delete { error in
                if let error = error {
                    promise(.failure(.unexpectedError("Failed to delete user data: \(error.localizedDescription)")))
                    return
                }

                user.delete { error in
                    if let error = error {
                        promise(.failure(.unexpectedError("Failed to delete account: \(error.localizedDescription)")))
                    } else {
                        do {
                            try Auth.auth().signOut()
                            promise(.success(()))
                        } catch {
                            promise(.failure(.unexpectedError("Sign-out failed after deletion: \(error.localizedDescription)")))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension FirebaseAuthService {
    func validateUsername(_ username: String) -> Result<Void, UsernameValidationError> {
        if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .failure(.empty)
        }

        if username.count < 3 {
            return .failure(.tooShort)
        }

        if username.count > 20 {
            return .failure(.tooLong)
        }

        let regex = "^[\\p{L}0-9_]+$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: username)
        if !isValid {
            return .failure(.invalidCharacters)
        }

        return .success(())
    }
    enum UsernameValidationError: String, Error {
        case empty = "Пайдаланушы аты бос болмауы керек"
        case tooShort = "Пайдаланушы аты кемінде 3 таңбадан тұруы керек"
        case tooLong = "Пайдаланушы аты 20 таңбадан аспауы керек"
        case invalidCharacters = "Пайдаланушы аты тек әріптерден, сандардан және астыңғы сызықтан тұруы керек"
    }
}
