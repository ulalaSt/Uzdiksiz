//
//  BackgroundGradientModifier.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 27.08.2025.
//

import SwiftUI

struct BackgroundGradientModifier: ViewModifier {
    var edges: Edge.Set = .all  // default to all edges

    func body(content: Content) -> some View {
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

extension View {
    func backgroundGradient(ignoring edges: Edge.Set = .all) -> some View {
        self.modifier(BackgroundGradientModifier(edges: edges))
    }
}
