//
//  SceneDelegate.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 4/2/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
                   willConnectTo session: UISceneSession,
                   options connectionOptions: UIScene.ConnectionOptions) {

            guard let windowScene = scene as? UIWindowScene else { return }

            let window = UIWindow(windowScene: windowScene)

            // Create your root VCs
            let casesVC = CasesViewController()
            casesVC.title = "Case"
            let casesNav = UINavigationController(rootViewController: casesVC)
            casesNav.tabBarItem = UITabBarItem(title: "Case",
                                               image: UIImage(systemName: "shippingbox.fill"),
                                               tag: 0)

            let collectionVC = CollectionViewController()
            collectionVC.title = "Collection"
            let collectionNav = UINavigationController(rootViewController: collectionVC)
            collectionNav.tabBarItem = UITabBarItem(title: "Collection",
                                                    image: UIImage(systemName: "archivebox.fill"),
                                                    tag: 1)

            let tabBar = UITabBarController()
            tabBar.viewControllers = [casesNav, collectionNav]
            tabBar.tabBar.backgroundColor = .systemBackground

            window.rootViewController = tabBar
            self.window = window
            window.makeKeyAndVisible()
        }
}

