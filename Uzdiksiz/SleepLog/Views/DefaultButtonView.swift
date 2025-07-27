//
//  DefaultButtonView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 27.07.2025.
//
import SwiftUI

struct DefaultButtonView: View {
    var title: String
    var body: some View {
        Text(title)
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .medium))
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
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
    }
}
