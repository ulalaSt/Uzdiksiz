//
//  View+Extensions.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 09.09.2025.
//
import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension View {
    @ViewBuilder
    func modify(@ViewBuilder _ transform: (Self) -> (some View)?) -> some View {
        if let view = transform(self), !(view is EmptyView) {
            view
        } else {
            self
        }
    }
}

struct GlassBackgroundModifier<S: Shape>: ViewModifier {
    @EnvironmentObject private var appState: AppState
    
    var shape: S
    var fallbackColor: Color
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *), appState.isGlassEffectEnabled {
            content
                .glassEffect(.clear, in: shape)
        } else {
            content
                .background(fallbackColor)
                .clipShape(shape)
        }
    }
}

extension View {
    func glassBackground<S: Shape>(
        _ shape: S = RoundedRectangle(cornerRadius: 16),
        fallbackColor: Color = .backgroundDeepNavy
    ) -> some View {
        self.modifier(GlassBackgroundModifier(shape: shape, fallbackColor: fallbackColor))
    }
}
