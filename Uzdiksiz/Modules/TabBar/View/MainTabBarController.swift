//
//  MainTabBarController.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 08.08.2025.
//

import UIKit

import SwiftUI

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    private let bgImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "night_bg"))
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        // Insert background at index 0
        view.insertSubview(bgImageView, at: 0)
        
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
       if #available(iOS 18, *) {
         guard let fromView = selectedViewController?.view,
               let toView = viewController.view,
               fromView != toView else {
           return viewController != selectedViewController
         }
   
         // Custom transition, to "hide" blinking
         UIView.transition(
             from: fromView, to: toView,
             duration: 0.01, // almost immediately
             options: [.transitionCrossDissolve]
         ) { _ in }
       }
       
      return viewController != selectedViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
