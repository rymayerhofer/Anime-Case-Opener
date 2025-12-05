//
//  CharacterLoader.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/19/25.
//

import Foundation

final class CharacterLoader {

    static let shared = CharacterLoader()

    private let adapter = JikanCharacterAdapter.shared
    private let factory = CharacterFactory.shared
    private let storage = CharacterStorage.shared

    func loadCharacters() {
        Task {
            do {
                var page = 1
                let limit = 25

                while (page < 100) {

                    let pageData = try await JikanAPIService.shared.fetchWithRetry({
                        try await JikanAPIService.shared.fetchTopPage(page: page, limit: limit)})

                    guard let json = try JSONSerialization.jsonObject(with: pageData) as? [String: Any],
                          let items = json["data"] as? [[String: Any]] else {
                        break
                    }

                    for item in items {
                        
                        guard let charID = item["mal_id"] as? Int else { continue }
                        
                        if await storage.isStored(charID) {
                            print ("[Loader] Skipping already stored character with ID: \(charID)")
                            continue
                        }

                        let parsed = try await adapter.adaptCharacter(for: item)
                        let character = factory.createCharacter(from: parsed)

                        await storage.appendToUnowned(character)
                        print("[Loader] persisted character to unowned: \(character.name) (\(character.charID))")
                    }

                    if let pagination = json["pagination"] as? [String: Any],
                       let hasNext = pagination["has_next_page"] as? Bool,
                       hasNext == false {
                        break
                    }

                    page += 1
                }
            } catch {
                print("[Loader] Prefetch failed:", error)
            }
        }
    }
}
