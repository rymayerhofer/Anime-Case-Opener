//
//  CharacterLoader.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/19/25.
//

import Foundation

/// Singleton responsible for fetching and caching the top characters, their voices, and their anime appearances.
final class CharacterLoader {

    static let shared = CharacterLoader()

    let service = JikanAPIService.shared
    let adapter = JikanCharacterAdapter.shared
    let storage = CharacterStorage.shared
    
    private let requestDelay: UInt64 = 500_000_000

    func loadCharacters() {
        Task {
            do {
                var voicesDict: [Int: [String: Any]] = [:]
                var animeDict: [Int: [String: Any]] = [:]
                var mangaDict: [Int: [String: Any]] = [:]

                var page = 1
                let limit = 25

                while (page < 100) {
                    
                    let pageData = try await fetchWithRetry { try await self.service.fetchTopPage(page: page, limit: limit) }

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

                        let voiceData = try await fetchWithRetry { try await self.service.fetchVoices(forCharacterID: charID) }
                        if let voiceJSON = try JSONSerialization.jsonObject(with: voiceData) as? [String: Any] {
                            voicesDict[charID] = voiceJSON
                        }

                        let animeData = try await fetchWithRetry { try await self.service.fetchAnime(forCharacterID: charID) }
                        if let animeJSON = try JSONSerialization.jsonObject(with: animeData) as? [String: Any] {
                            animeDict[charID] = animeJSON
                        }

                        let mangaData = try await fetchWithRetry { try await self.service.fetchManga(forCharacterID: charID) }
                        if let mangaJSON = try JSONSerialization.jsonObject(with: mangaData) as? [String: Any] {
                            mangaDict[charID] = mangaJSON
                        }

                        let character = try adapter.adaptCharacter(from: item, voicesDict: voicesDict, animeDict: animeDict, mangaDict: mangaDict)

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


    /// Simple sequential fetch with retry on rate-limit errors
    private func fetchWithRetry(_ block: @escaping () async throws -> Data) async throws -> Data {
        while true {
            do {
                let data = try await block()
                try await Task.sleep(nanoseconds: requestDelay)
                return data
            } catch {
                // Assuming the service throws a RateLimitError or HTTP 429
                if (error as? JikanAPIService.ServiceError) == .rateLimited {
                    print("[Loader] Rate limited, retrying after delay...")
                    try await Task.sleep(nanoseconds: 400_000_000)
                } else {
                    throw error
                }
            }
        }
    }
}
