//
//  MangaCharacter.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/19/25.
//

import Foundation

class MangaCharacter: Character, Manga {
    
    var mangaID: Int
    var mangaName: String
    var mangaURL: URL
    
    init(charID: Int, name: String, imageURL: URL, charURL: URL, favorites: Int,
         mangaID: Int, mangaName: String, mangaURL: URL) {
        
        self.mangaID = mangaID
        self.mangaName = mangaName
        self.mangaURL = mangaURL
        
        super.init(charID: charID, name: name, imageURL: imageURL, charURL: charURL, favorites: favorites)
    }
    
    // MARK: - Codable
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MangaCodingKeys.self)
        mangaID = try container.decode(Int.self, forKey: .mangaID)
        mangaName = try container.decode(String.self, forKey: .mangaName)
        mangaURL = try container.decode(URL.self, forKey: .mangaURL)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: MangaCodingKeys.self)
        try container.encode(mangaID, forKey: .mangaID)
        try container.encode(mangaName, forKey: .mangaName)
        try container.encode(mangaURL, forKey: .mangaURL)
    }
    
    // MARK: - Display
    
    override func displayInfoItems() -> [InfoItem] {
        var items = super.displayInfoItems()
        
        items.append(InfoItem(label: "Manga", value: mangaName, url: nil))
        items.append(InfoItem(label: "Manga Page", value: mangaURL.absoluteString.replacingOccurrences(of: "https://", with: ""), url: mangaURL))
        
        return items
    }
}
