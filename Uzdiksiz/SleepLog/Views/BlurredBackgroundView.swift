//
//  BlurredBackgroundView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 29.07.2025.
//

import SwiftUI

struct BlurredBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 53/255, green: 63/255, blue: 84/255),   // #353F54
                Color(red: 34/255, green: 40/255, blue: 52/255)    // #222834
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.6)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white,
                            .black
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ).opacity(0.2), lineWidth: 2
                )
                .padding(1)
        })
        .shadow(
            color: Color(red: 59/255, green: 71/255, blue: 95/255).opacity(0.5),
            radius: 20,
            x: 0,
            y: -20
        )
        .shadow(
            color: Color(red: 16/255, green: 20/255, blue: 28/255).opacity(0.6),
            radius: 20,
            x: 0,
            y: 20
        )
    }
}
