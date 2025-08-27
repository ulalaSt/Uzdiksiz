//
//  CardRow.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 27.08.2025.
//

import SwiftUI

struct CardRow<Content: View>: View {
    let systemIcon: String
    let title: String
    let caption: String?
    let content: () -> Content?
    let action: (() -> Void)?

    init(systemIcon: String,
         title: String,
         caption: String? = nil,
         @ViewBuilder content: @escaping () -> Content? = { Optional<EmptyView>.init(nilLiteral: ()) },
         action: (() -> Void)?) {
        self.systemIcon = systemIcon
        self.title = title
        self.caption = caption
        self.content = content
        self.action = action
    }

    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 4) {
                    Image(systemName: systemIcon)
                        .foregroundColor(.white)
                    
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundColor(.textSoftWhite)

                    Spacer()

                    if let caption = caption {
                        Text(caption)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.textLightGray)
                    }

                    Image(systemName: "chevron.right")
                        .foregroundColor(.textLightGray)
                }
                content()
            }
            .padding(16)
            .background(Color.backgroundDeepNavy)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
