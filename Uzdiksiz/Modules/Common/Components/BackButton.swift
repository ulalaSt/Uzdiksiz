//
//  BackButton.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 01.08.2025.
//

import SwiftUI

struct BackButton: View {
    var body: some View {
        Image(systemName: "chevron.left")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 34, height: 34, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 52/255, green: 200/255, blue: 232/255), location: 0.0),
                                .init(color: Color(red: 78/255, green: 74/255, blue: 242/255), location: 1),
                            ]),
                            startPoint: UnitPoint(x: 0.49, y: 0.0),
                            endPoint: UnitPoint(x: 0.5, y: 1.0)
                        )
                    )
                    .overlay(
                        GeometryReader(content: { proxy in
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: Color.white.opacity(0.6), location: 0.0),
                                            .init(color: Color.black.opacity(0.6), location: 1)
                                        ]),
                                        startPoint: UnitPoint(x: 0.49, y: 0.0),
                                        endPoint: UnitPoint(x: 0.5, y: 1.0)
                                    ),
                                    lineWidth: 2
                                )
                        })
                    )
            )
            .padding(5)
    }
}
