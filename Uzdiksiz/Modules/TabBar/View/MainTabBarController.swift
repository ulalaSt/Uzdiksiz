//
//  MainTabBarController.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 08.08.2025.
//

import UIKit

import SwiftUI

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
    }

    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backgroundMidnightBlue

        // Normal (unselected) item color
        appearance.stackedLayoutAppearance.normal.iconColor = .textLightGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.textLightGray]

        // Selected item color
        appearance.stackedLayoutAppearance.selected.iconColor = .primaryOceanBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.primaryOceanBlue]

        // Apply to the tab bar
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
