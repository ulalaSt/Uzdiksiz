//
//  AuthViewModel.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//

import FirebaseAuth
import Combine
import FirebaseCore
import FirebaseFirestore
import AuthenticationServices
import CryptoKit
import GoogleSignIn

class AuthViewModel: NSObject, ObservableObject {
    @Published var user: Loadable<AppUser>
    @Published var deleteState: Loadable<Void> = .notRequested
    @Published var signoutState: Loadable<Void> = .notRequested
    private var cancelBag = CancelBag()
    private var db = Firestore.firestore()
    private let service: AuthService
    private let appState: AppState
    weak var coordinatorDelegate: AuthCoordinatorDelegate?
    
    init(appState: AppState, service: AuthService) {
        self.appState = appState
        self.service = service
        self.user = appState.user
        super.init()
        self.appState.$user.assign(to: \.user, on: self).store(in: cancelBag)
    }

    func signIn(email: String, password: String) {
        service.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String, nickname: String) {
        service.signUp(email: email, password: password, nickname: nickname)
    }

    func signInWithGoogle() {
        guard let config = service.getGoogleConfig() else {
            return
        }
        coordinatorDelegate?.startGoogleSignIn(config, completion: { [weak self] result, error in
            self?.service.signInWithGoogle(result: result, error: error)
        })
    }
    
    func signInWithApple() {
        let nonce = randomNonceString()
        coordinatorDelegate?.startAppleSignIn(nonce: nonce, completion: { [weak self] authorization in
            self?.service.signInWithApple(authorization: authorization, nonce: nonce)
        })
    }

    func signOut() {
        service.signOut().sinkToLoadable { [weak self] result in
            self?.signoutState = result
        }.store(in: cancelBag)
    }

    func deleteAccount() {
        service.deleteAccount().sinkToLoadable { [weak self] result in
            self?.deleteState = result
        }.store(in: cancelBag)
    }
}

fileprivate func randomNonceString(length: Int = 32) -> String {
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

