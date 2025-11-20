//
//  FullCharacter.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/19/25.
//

import Foundation

class FullCharacter: Character, Anime, Manga {
    
    var animeID: Int
    var animeName: String
    var animeURL: URL
    var vaID: Int
    var vaName: String
    var vaURL: URL
    
    var mangaID: Int
    var mangaName: String
    var mangaURL: URL
    
    init(charID: Int, name: String, imageURL: URL, charURL: URL, favorites: Int,
         animeID: Int, animeName: String, animeURL: URL,
         vaID: Int, vaName: String, vaURL: URL,
         mangaID: Int, mangaName: String, mangaURL: URL) {
        
        self.animeID = animeID
        self.animeName = animeName
        self.animeURL = animeURL
        self.vaID = vaID
        self.vaName = vaName
        self.vaURL = vaURL
        
        self.mangaID = mangaID
        self.mangaName = mangaName
        self.mangaURL = mangaURL
        
        super.init(charID: charID, name: name, imageURL: imageURL, charURL: charURL, favorites: favorites)
    }
    
    // MARK: - Codable
    
    required init(from decoder: Decoder) throws {
        let animeContainer = try decoder.container(keyedBy: AnimeCodingKeys.self)
        animeID = try animeContainer.decode(Int.self, forKey: .animeID)
        animeName = try animeContainer.decode(String.self, forKey: .animeName)
        animeURL = try animeContainer.decode(URL.self, forKey: .animeURL)
        vaID = try animeContainer.decode(Int.self, forKey: .vaID)
        vaName = try animeContainer.decode(String.self, forKey: .vaName)
        vaURL = try animeContainer.decode(URL.self, forKey: .vaURL)
        
        let mangaContainer = try decoder.container(keyedBy: MangaCodingKeys.self)
        mangaID = try mangaContainer.decode(Int.self, forKey: .mangaID)
        mangaName = try mangaContainer.decode(String.self, forKey: .mangaName)
        mangaURL = try mangaContainer.decode(URL.self, forKey: .mangaURL)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var animeContainer = encoder.container(keyedBy: AnimeCodingKeys.self)
        try animeContainer.encode(animeID,   forKey: .animeID)
        try animeContainer.encode(animeName, forKey: .animeName)
        try animeContainer.encode(animeURL,  forKey: .animeURL)
        try animeContainer.encode(vaID,   forKey: .vaID)
        try animeContainer.encode(vaName, forKey: .vaName)
        try animeContainer.encode(vaURL,  forKey: .vaURL)
        
        var mangaContainer = encoder.container(keyedBy: MangaCodingKeys.self)
        try mangaContainer.encode(mangaID, forKey: .mangaID)
        try mangaContainer.encode(mangaName, forKey: .mangaName)
        try mangaContainer.encode(mangaURL, forKey: .mangaURL)
    }
    
    // MARK: - Display
    
    override func displayInfoItems() -> [InfoItem] {
        var items = super.displayInfoItems()

        items.append(InfoItem(label: "Anime", value: animeName, url: nil))
        items.append(InfoItem(label: "Anime Page", value: animeURL.absoluteString.replacingOccurrences(of: "https://", with: ""), url: animeURL))
        items.append(InfoItem(label: "VA", value: vaName, url: nil))
        items.append(InfoItem(label: "VA Page", value: vaURL.absoluteString.replacingOccurrences(of: "https://", with: ""), url: vaURL))
        
        items.append(InfoItem(label: "Manga", value: mangaName, url: nil))
        items.append(InfoItem(label: "Manga Page", value: mangaURL.absoluteString.replacingOccurrences(of: "https://", with: ""), url: mangaURL))
        
        return items
    }
}
