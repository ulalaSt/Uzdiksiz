//
//  AuthCoordinator.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 04.08.2025.
//
import UIKit
import FirebaseCore
import GoogleSignIn
import SwiftUI
import AuthenticationServices
import CryptoKit

class AuthCoordinator: NSObject, Coordinator {
    private let navigationController: UINavigationController
    private let appState: AppState
    private let environment: AppEnvironment
    var appleSignInCompletion: ((ASAuthorization) -> Void)? = nil
    private let authViewModel: AuthViewModel
    
    init(navigationController: UINavigationController, appState: AppState, environment: AppEnvironment, authViewModel: AuthViewModel) {
        self.navigationController = navigationController
        self.appState = appState
        self.environment = environment
        self.authViewModel = authViewModel
    }

    func start() {
        authViewModel.coordinatorDelegate = self
        let loginView = LoginView(authViewModel: authViewModel)
        let hostingController = UIHostingController(rootView: loginView)
        navigationController.setViewControllers([hostingController], animated: false)
    }
    
    func stop() {
        
    }
}

extension AuthCoordinator: AuthCoordinatorDelegate {
    func startAppleSignIn(nonce: String, completion: ((ASAuthorization) -> Void)?) {
        appleSignInCompletion = completion
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func startGoogleSignIn(_ config: GIDConfiguration, completion: ((GIDSignInResult?, (any Error)?) -> Void)?) {
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self.navigationController, completion: completion)
    }
}

extension AuthCoordinator: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        appleSignInCompletion?(authorization)
        appleSignInCompletion = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        appState.user = .failed(.unexpectedError("Apple авторизация қатесі: \(error.localizedDescription)"))
    }
}

fileprivate func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.map { String(format: "%02x", $0) }.joined()
}
