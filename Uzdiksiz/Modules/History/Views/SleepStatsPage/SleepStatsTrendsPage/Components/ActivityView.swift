//
//  ActivityView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 17.09.2025.
//

import UIKit
import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return vc
    }
    
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
