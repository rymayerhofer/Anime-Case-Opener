//
//  AppDelegate.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 4/2/25.
//

import UIKit
import Nuke

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureNuke()
        CharacterLoader.shared.loadCharacters()
        return true
    }

    // MARK: - Nuke Configuration

    func configureNuke() {
        let cache = ImageCache()
        cache.costLimit = 200 * 1024 * 1024 // 200 MB (tune as needed)

        var config = ImagePipeline.Configuration()
        config.isProgressiveDecodingEnabled = true
        config.imageCache = cache

        ImagePipeline.shared = ImagePipeline(configuration: config)
    }
}
