//
//  JikanCharacterAdapter.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/19/25.
//

import Foundation

final class JikanCharacterAdapter {
    
    static let shared = JikanCharacterAdapter()

    func adaptCharacter(
        from dict: [String: Any],
        voicesDict: [Int: [String: Any]],
        animeDict: [Int: [String: Any]],
        mangaDict: [Int: [String: Any]]
    ) throws -> Character {

        guard
            let id = dict["mal_id"] as? Int,
            let name = dict["name"] as? String,
            let urlStr = dict["url"] as? String,
            let url = URL(string: urlStr),
            let images = dict["images"] as? [String: Any],
            let jpg = images["jpg"] as? [String: Any],
            let imgURLStr = jpg["image_url"] as? String,
            let imgURL = URL(string: imgURLStr)
        else {
            throw NSError(domain: "InvalidCharacterData", code: 0)
        }
        print("[Adapter] Adapting character \(id): \(name)")

        let favorites = dict["favorites"] as? Int ?? 0

        var vaID: Int? = nil
        var vaName: String? = nil
        var vaURL: URL? = nil

        if let voiceJSON = voicesDict[id],
           let arr = voiceJSON["data"] as? [[String: Any]] {
            if let japaneseVA = arr.first(where: {
                ($0["language"] as? String)?.lowercased() == "japanese"
            }), let person = japaneseVA["person"] as? [String: Any] {
                vaID   = person["mal_id"] as? Int
                vaName = person["name"] as? String
                if let pURL = person["url"] as? String {
                    vaURL = URL(string: pURL)
                }
                print("[Adapter] VA extracted: ID=\(vaID?.description ?? "nil"), name=\(vaName ?? "nil")")
            }
        }

        var animeID: Int? = nil
        var animeName: String? = nil
        var animeURL: URL? = nil

        if let animeJSON = animeDict[id],
           let arr = animeJSON["data"] as? [[String: Any]] {
            if let first = arr.first,
               let animeObj = first["anime"] as? [String: Any] {
                animeID   = animeObj["mal_id"] as? Int
                animeName = animeObj["title"] as? String
                if let aURL = animeObj["url"] as? String {
                    animeURL = URL(string: aURL)
                }
                print("[Adapter] Anime extracted: ID=\(animeID?.description ?? "nil"), title=\(animeName ?? "nil")")
            }
        }

        var mangaID: Int? = nil
        var mangaName: String? = nil
        var mangaURL: URL? = nil

        if let mangaJSON = mangaDict[id],
           let arr = mangaJSON["data"] as? [[String: Any]] {
            if let first = arr.first,
               let mangaObj = first["manga"] as? [String: Any] {
                mangaID   = mangaObj["mal_id"] as? Int
                mangaName = mangaObj["title"] as? String
                if let mURL = mangaObj["url"] as? String {
                    mangaURL = URL(string: mURL)
                }
                print("[Adapter] Manga extracted: ID=\(mangaID?.description ?? "nil"), title=\(mangaName ?? "nil")")
            }
        }

        if let animeID, let animeName, let animeURL,
           let vaID, let vaName, let vaURL,
           let mangaID, let mangaName, let mangaURL {
            print("[Adapter] Character \(id) made as full character")
            return FullCharacter(
                charID: id,
                name: name,
                imageURL: imgURL,
                charURL: url,
                favorites: favorites,
                animeID: animeID,
                animeName: animeName,
                animeURL: animeURL,
                vaID: vaID,
                vaName: vaName,
                vaURL: vaURL,
                mangaID: mangaID,
                mangaName: mangaName,
                mangaURL: mangaURL
            )

        } else if let animeID, let animeName, let animeURL,
                  let vaID, let vaName, let vaURL {
            print("[Adapter] Character \(id) made as anime-only character")
            return AnimeCharacter(
                charID: id,
                name: name,
                imageURL: imgURL,
                charURL: url,
                favorites: favorites,
                animeID: animeID,
                animeName: animeName,
                animeURL: animeURL,
                vaID: vaID,
                vaName: vaName,
                vaURL: vaURL
            )

        } else if let mangaID, let mangaName, let mangaURL {
            print("[Adapter] Character \(id) made as manga-only character")
            return MangaCharacter(
                charID: id,
                name: name,
                imageURL: imgURL,
                charURL: url,
                favorites: favorites,
                mangaID: mangaID,
                mangaName: mangaName,
                mangaURL: mangaURL
            )

        } else {
            print("[Adapter] Character \(id) made as base character")
            return Character(
                charID: id,
                name: name,
                imageURL: imgURL,
                charURL: url,
                favorites: favorites
            )
        }
    }
}
