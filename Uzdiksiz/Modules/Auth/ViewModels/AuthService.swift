//
//  AuthService.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 04.08.2025.
//

import Foundation
import FirebaseAuth
import Combine
import AuthenticationServices
import UIKit
import GoogleSignIn

protocol AuthService {
    var user: Loadable<AppUser> { get }
    var userPublisher: AnyPublisher<Loadable<AppUser>, Never> { get }
    func signUp(email: String, password: String, nickname: String)
    func signIn(email: String, password: String)
    func getGoogleConfig() -> GIDConfiguration?
    func signInWithGoogle(result: GIDSignInResult?, error: Error?)
    func signInWithApple(authorization: ASAuthorization, nonce: String)
    func signOut() -> AnyPublisher<Void, APIError>
    func deleteAccount() -> AnyPublisher<Void, APIError>
}
