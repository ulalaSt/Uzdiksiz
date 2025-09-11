//
//  AuthCoordinatorDelegate.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 06.08.2025.
//
import GoogleSignIn
import AuthenticationServices

protocol AuthCoordinatorDelegate: AnyObject {
    func startGoogleSignIn(_ config: GIDConfiguration, completion: ((GIDSignInResult?, (any Error)?) -> Void)?)
    func startAppleSignIn(nonce: String, completion: ((ASAuthorization) -> Void)?)
}
