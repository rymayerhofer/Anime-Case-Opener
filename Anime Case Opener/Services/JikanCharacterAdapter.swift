//
//  JikanCharacterAdapter.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/19/25.
//

import Foundation

final class JikanCharacterAdapter {
    
    static let shared = JikanCharacterAdapter()
    
    private let service = JikanAPIService.shared

    private let requestDelay: UInt64 = 500_000_000
    private let retryDelay: UInt64 = 400_000_000

    func adaptCharacter(for item: [String: Any]) async throws -> (
        id: Int,
        name: String,
        charURL: URL,
        imageURL: URL,
        favorites: Int,
        va: (id: Int, name: String, url: URL)?,
        anime: (id: Int, title: String, url: URL)?,
        manga: (id: Int, title: String, url: URL)?
    ) {
        guard
            let id = item["mal_id"] as? Int,
            let name = item["name"] as? String,
            let urlStr = item["url"] as? String,
            let charURL = URL(string: urlStr),
            let images = item["images"] as? [String: Any],
            let jpg = images["jpg"] as? [String: Any],
            let imgURLStr = jpg["image_url"] as? String,
            let imageURL = URL(string: imgURLStr),
            let favorites = item["favorites"] as? Int
        else {
            throw NSError(domain: "InvalidCharacterData", code: 0)
        }
        print("[Adapter] Parsing character \(id): \(name)")
        
        let voicesAny = try JSONSerialization.jsonObject(with: try await service.fetchWithRetry { try await self.service.fetchVoices(forCharacterID: id)})
        let voicesJSON = voicesAny as? [String: Any]
        var vaResult: (id: Int, name: String, url: URL)? = nil
        if let voices = voicesJSON,
           let arr = voices["data"] as? [[String: Any]] {
            if let japaneseVA = arr.first(where: {
                ($0["language"] as? String)?.lowercased() == "japanese"
            }), let person = japaneseVA["person"] as? [String: Any],
               let pID = person["mal_id"] as? Int,
               let pName = person["name"] as? String,
               let pURLStr = person["url"] as? String,
               let pURL = URL(string: pURLStr) {
                vaResult = (id: pID, name: pName, url: pURL)
                print("[Adapter] VA extracted: ID=\(vaResult!.id), name=\(vaResult!.name)")
            }
        }
        
        let animeAny = try JSONSerialization.jsonObject(with: try await service.fetchWithRetry { try await self.service.fetchAnime(forCharacterID: id)})
        let animeJSON = animeAny as? [String: Any]
        var animeResult: (id: Int, title: String, url: URL)? = nil
        if let anime = animeJSON,
           let arr = anime["data"] as? [[String: Any]],
           let first = arr.first,
           let animeObj = first["anime"] as? [String: Any],
           let aID = animeObj["mal_id"] as? Int,
           let aTitle = animeObj["title"] as? String,
           let aURLStr = animeObj["url"] as? String,
           let aURL = URL(string: aURLStr) {
            animeResult = (id: aID, title: aTitle, url: aURL)
            print("[Adapter] Anime extracted: ID=\(animeResult!.id), title=\(animeResult!.title)")
        }
        
        let mangaAny = try JSONSerialization.jsonObject(with: try await service.fetchWithRetry { try await self.service.fetchManga(forCharacterID: id)})
        let mangaJSON = mangaAny as? [String: Any]
        var mangaResult: (id: Int, title: String, url: URL)? = nil
        if let manga = mangaJSON,
           let arr = manga["data"] as? [[String: Any]],
           let first = arr.first,
           let mangaObj = first["manga"] as? [String: Any],
           let mID = mangaObj["mal_id"] as? Int,
           let mTitle = mangaObj["title"] as? String,
           let mURLStr = mangaObj["url"] as? String,
           let mURL = URL(string: mURLStr) {
            mangaResult = (id: mID, title: mTitle, url: mURL)
            print("[Adapter] Manga extracted: ID=\(mangaResult!.id), title=\(mangaResult!.title)")
        }

        return (
            id: id,
            name: name,
            charURL: charURL,
            imageURL: imageURL,
            favorites: favorites,
            va: vaResult,
            anime: animeResult,
            manga: mangaResult
        )
    }
}
