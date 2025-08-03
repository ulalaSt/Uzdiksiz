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
import AuthenticationServices
import CryptoKit

class AuthViewModel: NSObject, ObservableObject {
    @Published var user: Loadable<User?> = .notRequested
    private var cancelBag = CancelBag()
    private var db = Firestore.firestore()
    private var currentNonce: String?

    override init() {
        super.init()
        Auth.auth().languageCode = "ru"
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
    
    func performAppleSignIn() {
        let nonce = randomNonceString()
        currentNonce = nonce

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) {
        user.setIsLoading(cancelBag: cancelBag)
        guard let token = credential.identityToken,
              let tokenString = String(data: token, encoding: .utf8) else {
            user = .failed(.clientError("Apple identity token is missing."))
            return
        }

        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: tokenString,
            rawNonce: ""
        )

        Auth.auth().signIn(with: firebaseCredential) { [weak self] result, error in
            if let error = error {
                self?.user = .failed(.unexpectedError(error.localizedDescription))
            } else {
                self?.user = .loaded(result?.user)
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


extension AuthViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Показываем с главным окном
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first { $0.isKeyWindow } ?? UIWindow()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = appleIDCredential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8),
              let nonce = currentNonce else {
            self.user = .failed(.clientError("Apple авторизация сәтсіз аяқталды."))
            return
        }

        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)

        Auth.auth().signIn(with: credential) { [weak self] result, error in
            if let error = error {
                self?.user = .failed(.unexpectedError("Firebase қате: \(error.localizedDescription)"))
            } else {
                self?.user = .loaded(result?.user)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.user = .failed(.unexpectedError("Apple авторизация қатесі: \(error.localizedDescription)"))
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }

    func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var random: UInt8 = 0
            if SecRandomCopyBytes(kSecRandomDefault, 1, &random) == errSecSuccess {
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}
