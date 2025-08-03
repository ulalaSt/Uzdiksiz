//
//  ContentView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 21.03.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            switch authViewModel.user {
            case .notRequested:
                ProgressView("Сеанс тексерілуде...")
            case .isLoading(let last, _):
                if let last, last != nil {
                    MainView(authViewModel: authViewModel)
                } else {
                    LoginView(authViewModel: authViewModel)
                }
            case .loaded(let t):
                if t != nil {
                    MainView(authViewModel: authViewModel)
                } else {
                    LoginView(authViewModel: authViewModel)
                }
            case .failed:
                LoginView(authViewModel: authViewModel)
            }
        }
        .animation(.default, value: authViewModel.user.isLoading)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 34/255, green: 40/255, blue: 52/255).ignoresSafeArea())
    }
}
