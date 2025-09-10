//
//  LongPressDragGestureOverlay.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 09.09.2025.
//
import SwiftUI

struct LongPressDragGestureOverlay: UIViewRepresentable {
    @Binding var location: CGPoint?

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        let gesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleGesture(_:))
        )
        gesture.minimumPressDuration = 0.3
        gesture.allowableMovement = 10
        view.addGestureRecognizer(gesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(location: $location)
    }

    class Coordinator: NSObject {
        @Binding var location: CGPoint?

        init(location: Binding<CGPoint?>) {
            _location = location
        }

        @objc func handleGesture(_ gesture: UILongPressGestureRecognizer) {
            switch gesture.state {
            case .began, .changed:
                location = gesture.location(in: gesture.view)
            case .ended, .cancelled, .failed:
                location = nil
            default:
                break
            }
        }
    }
}
