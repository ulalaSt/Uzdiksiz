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
            if authViewModel.isLoading {
                ProgressView("Checking session...")
            } else if let _ = authViewModel.user {
                MainView(authViewModel: authViewModel) // ✅ your real app view (sleep logs etc.)
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
        .animation(.default, value: authViewModel.isLoading)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 34/255, green: 40/255, blue: 52/255).ignoresSafeArea())
    }
}
