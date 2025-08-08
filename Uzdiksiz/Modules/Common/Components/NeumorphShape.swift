//
//  NeumorphShape.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 03.08.2025.
//

import SwiftUI

struct NeumorphShape<S: Shape>: View {
    var shape: S
    var fill: Color = Color(red: 40/255, green: 48/255, blue: 63/255)
    var darkShadow: Color = Color(red: 25/255, green: 30/255, blue: 40/255)
    var lightShadow: Color = Color(red: 54/255, green: 64/255, blue: 85/255)

    var body: some View {
        shape
            .fill(fill)
            .overlay(
                shape
                    .stroke(darkShadow, lineWidth: 4)
                    .blur(radius: 3)
                    .offset(x: 2, y: 2)
                    .mask(
                        shape.fill(
                            LinearGradient(
                                colors: [Color.black, .clear],
                                startPoint: .init(x: 0.95, y: 0),
                                endPoint: .init(x: 1, y: 1)
                            )
                        )
                    )
            )
            .overlay(
                shape
                    .stroke(lightShadow, lineWidth: 8)
                    .blur(radius: 3)
                    .offset(x: -2, y: -2)
                    .mask(
                        shape.fill(
                            LinearGradient(
                                colors: [.clear, Color.black],
                                startPoint: .init(x: 0.99, y: 0),
                                endPoint: .init(x: 1, y: 1)
                            )
                        )
                    )
            )
            .overlay(
                shape
                    .stroke(
                        LinearGradient(colors: [.clear, .white.opacity(0.2)], startPoint: .init(x: 0.99, y: 0), endPoint: .init(x: 1, y: 1)),
                        lineWidth: 1
                    )
            )
    }
}
