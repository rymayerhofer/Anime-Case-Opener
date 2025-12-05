//
//  CharacterFactory.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 12/4/25.
//

import Foundation

final class CharacterFactory {

    static let shared = CharacterFactory()

    func createCharacter(from parsed: (
        id: Int,
        name: String,
        charURL: URL,
        imageURL: URL,
        favorites: Int,
        va: (id: Int, name: String, url: URL)?,
        anime: (id: Int, title: String, url: URL)?,
        manga: (id: Int, title: String, url: URL)?
    )) -> Character {

        let id = parsed.id
        let name = parsed.name
        let imageURL = parsed.imageURL
        let charURL = parsed.charURL
        let favorites = parsed.favorites

        if let anime = parsed.anime, let va = parsed.va, let manga = parsed.manga {
            print("[Factory] Character \(id) made as full character")
            return FullCharacter(
                charID: id,
                name: name,
                imageURL: imageURL,
                charURL: charURL,
                favorites: favorites,
                animeID: anime.id,
                animeName: anime.title,
                animeURL: anime.url,
                vaID: va.id,
                vaName: va.name,
                vaURL: va.url,
                mangaID: manga.id,
                mangaName: manga.title,
                mangaURL: manga.url
            )
        }

        if let anime = parsed.anime, let va = parsed.va {
            print("[Factory] Character \(id) made as anime-only character")
            return AnimeCharacter(
                charID: id,
                name: name,
                imageURL: imageURL,
                charURL: charURL,
                favorites: favorites,
                animeID: anime.id,
                animeName: anime.title,
                animeURL: anime.url,
                vaID: va.id,
                vaName: va.name,
                vaURL: va.url
            )
        }

        if let manga = parsed.manga {
            print("[Factory] Character \(id) made as manga-only character")
            return MangaCharacter(
                charID: id,
                name: name,
                imageURL: imageURL,
                charURL: charURL,
                favorites: favorites,
                mangaID: manga.id,
                mangaName: manga.title,
                mangaURL: manga.url
            )
        }

        print("[Factory] Character \(id) made as base character")
        return Character(
            charID: id,
            name: name,
            imageURL: imageURL,
            charURL: charURL,
            favorites: favorites
        )
    }
}
