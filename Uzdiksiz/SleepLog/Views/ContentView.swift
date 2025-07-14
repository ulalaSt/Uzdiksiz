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
                MainView() // ✅ your real app view (sleep logs etc.)
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
        .animation(.default, value: authViewModel.isLoading)
    }
}
