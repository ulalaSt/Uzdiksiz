//
//  DefaultButtonView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 27.07.2025.
//
import SwiftUI

struct DefaultButtonView: View {
    var title: String
    var isLoading: Bool = false
    var state: DefaultButtonType = .primary
    var body: some View {
        HStack(spacing: 4) {
            if isLoading {
                ProgressView()
                    .frame(width: 14, height: 14)
            }
            Text(title)
        }
        .foregroundColor(state == .primary || state == .tertiary ? .textSoftWhite : .backgroundMidnightBlue)
        .font(.headline.weight(.semibold))
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background {
            switch state {
            case .primary:
                gradientBg
            case .secondary:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.textSoftWhite)
            case .tertiary:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            }
        }
    }
    
    var gradientBg: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .colorsCyan, location: 0.0),
                        .init(color: .accentViolet, location: 1),
                    ]),
                    startPoint: UnitPoint(x: 0.49, y: 0.0),
                    endPoint: UnitPoint(x: 0.5, y: 1.0)
                )
            )
            .overlay(
                GeometryReader(content: { proxy in
                    RoundedRectangle(cornerRadius: 12)
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

    }
}

enum DefaultButtonType {
    case primary
    case secondary
    case tertiary
}
