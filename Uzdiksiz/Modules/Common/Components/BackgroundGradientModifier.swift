//
//  BackgroundGradientModifier.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 27.08.2025.
//

import SwiftUI

struct BackgroundGradientModifier: ViewModifier {
    var edges: Edge.Set = .all  // default to all edges
    @EnvironmentObject private var appState: AppState

    func body(content: Content) -> some View {
        if #available(iOS 26, *), appState.isGlassEffectEnabled {
            content
                .background(
                    Color.backgroundMidnightBlue.opacity(0.7)
                        .ignoresSafeArea(edges: edges) // respect the edges parameter
                )
                .background(
                    Image("apple_bg")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea(edges: edges) // respect the edges parameter
                )

        } else {
            content
                .background(
                    LinearGradient(
                        colors: [.backgroundDeepNavy, .backgroundMidnightBlue],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: edges) // respect the edges parameter
                )
        }
    }
}

extension View {
    func backgroundGradient(ignoring edges: Edge.Set = .all) -> some View {
        self.modifier(BackgroundGradientModifier(edges: edges))
    }
}

