//
//  LongPressButton.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 22.08.2025.
//

import SwiftUI

struct LongPressButton: View {
    let title: String
    let action: () -> Void
    
    @State private var progress: CGFloat = 0
    @State private var didComplete = false
    @State private var workItem: DispatchWorkItem?
    
    private let holdDuration: Double = 2
    
    var body: some View {
        Text(title)
            .foregroundColor(.backgroundDeepNavy)
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 50)
            .padding(.horizontal, 10)
            .background(
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Color.textSoftWhite
                        LinearGradient(
                            colors: [.colorsCyan, .accentViolet],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * progress, height: geo.size.height)
                    }
                }
            )
            .cornerRadius(12)
            .contentShape(Rectangle()) // make whole area tappable
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in startHolding() }
                    .onEnded { _ in finishHolding() }
            )
    }
    
    private func startHolding() {
        guard workItem == nil else { return } // prevent restarting mid-press
        didComplete = false
        progress = 0
        
        let item = DispatchWorkItem {
            didComplete = true
        }
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration, execute: item)
        
        withAnimation(.linear(duration: holdDuration)) {
            progress = 1.0
        }
    }
    
    private func finishHolding() {
        if didComplete {
            action()
        }
        reset()
    }
    
    private func reset() {
        workItem?.cancel()
        workItem = nil
        didComplete = false
        
        withAnimation(.easeOut(duration: 0.2)) {
            progress = 0
        }
    }
}
