//
//  LoginView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var state: AuthState = .login
    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 32) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Бүгіннен баста!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("Өзгерісті бастау үшін тіркеліңіз немесе жүйеге кіріңіз")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
            Spacer(minLength: 64)
            VStack(spacing: 24) {
                selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .foregroundColor(Color(red: 213/255, green: 213/255, blue: 213/255))
                        .font(.system(size: 12, weight: .medium))
                    TextField("", text: $email, prompt: Text("Email енгізіңіз").foregroundColor(Color(red: 125/255, green: 125/255, blue: 145/255)))
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(innerShadowBg)
                        .cornerRadius(10)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Құпиясөз")
                        .foregroundColor(Color(red: 213/255, green: 213/255, blue: 213/255))
                        .font(.system(size: 12, weight: .medium))
                    SecureField("", text: $password, prompt: Text("Құпиясөз енгізіңіз").foregroundColor(Color(red: 125/255, green: 125/255, blue: 145/255)))
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(innerShadowBg)
                        .cornerRadius(10)
                }
                if let error = authViewModel.user.error?.errorDescription {
                    Text(error)
                        .foregroundColor(Color(red: 255/255, green: 95/255, blue: 87/255))
                        .font(.system(size: 12, weight: .medium))
                        .multilineTextAlignment(.center)
                }
                Button {
                    switch state {
                    case .login:
                        authViewModel.signIn(email: email, password: password)
                    case .register:
                        authViewModel.signUp(email: email, password: password)
                    }
                } label: {
                    DefaultButtonView(title: state.title)
                }
                HStack(spacing: 16) {
                    Rectangle().fill(Color(red: 237/255, green: 241/255, blue: 243/255))
                        .frame(height: 1)
                    Text("Немесе")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(red: 108/255, green: 114/255, blue: 120/255))
                    Rectangle().fill(Color(red: 237/255, green: 241/255, blue: 243/255))
                        .frame(height: 1)
                }
                Button {
                    if let rootVC = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first?.windows.first?.rootViewController {
                        authViewModel.signInWithGoogle(presenting: rootVC)
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image("google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("Google-мен жалғастыру")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.1))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 239/255, green: 240/255, blue: 246/255).opacity(0.5), lineWidth: 1)
                            }
                    }
                }
                Button {
                    authViewModel.performAppleSignIn()
                } label: {
                    HStack(spacing: 10) {
                        Image("apple")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("Apple арқылы жалғастыру")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.1))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            }
                    }
                }
                Spacer()
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 53/255, green: 63/255, blue: 84/255, opacity: 1), location: 0.0),
                                .init(color: Color(red: 34/255, green: 40/255, blue: 52/255, opacity: 1), location: 1),
                            ]),
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .overlay(
                        GeometryReader(content: { proxy in
                            RoundedRectangle(cornerRadius: 30)
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: Color.white.opacity(0.2), location: 0.0),
                                            .init(color: Color.black.opacity(0.0), location: 30 / proxy.size.height)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        })
                    )
                    .ignoresSafeArea()
                    .shadow(
                        color: Color.black.opacity(0.25),
                        radius: 60,
                        x: 0,
                        y: -20
                    )
            )
        }
        .padding(.top, 24)
        .background(
            Image("stars_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
    
    var selector: some View {
        HStack(spacing: 10) {
            ForEach(AuthState.allCases) { option in
                Text(option.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(
                        state == option
                        ? Color(red: 35/255, green: 36/255, blue: 71/255)      // #232447
                        : Color(red: 125/255, green: 125/255, blue: 145/255)  // #7D7D91
                    )
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(
                        state == option ? RoundedRectangle(cornerRadius: 6).fill(Color.white).matchedGeometryEffect(id: "selector", in: animation) : nil
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            state = option
                        }
                    }
            }
        }
        .padding(5)
        .background(
            innerShadowBg
        )
    }
    
    var innerShadowBg: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(red: 40/255, green: 48/255, blue: 63/255))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white,
                            lineWidth: 32)
                    .padding(-16)
                    .shadow(color: Color(red: 25/255, green: 30/255, blue: 40/255),
                            radius: 6, x: 4, y: 4)
                    .shadow(color: Color(red: 54/255, green: 64/255, blue: 85/255), radius: 3, x: -4, y: -4)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )
            )
    }
        
    enum AuthState: CaseIterable, Identifiable {
        case login
        case register

        var id: AuthState { self }
        var title: String {
            switch self {
            case .login:
                "Кіру"
            case .register:
                "Тіркелу"
            }
        }
    }
}
