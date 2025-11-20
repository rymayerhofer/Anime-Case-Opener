//
//  AnimeCharacter.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/19/25.
//

import Foundation

class AnimeCharacter: Character, Anime {
    
    var animeID: Int
    var animeName: String
    var animeURL: URL
    var vaID: Int
    var vaName: String
    var vaURL: URL

    init(charID: Int, name: String, imageURL: URL, charURL: URL, favorites: Int,
         animeID: Int, animeName: String, animeURL: URL,
         vaID: Int, vaName: String, vaURL: URL) {
        
        self.animeID = animeID
        self.animeName = animeName
        self.animeURL = animeURL
        self.vaID = vaID
        self.vaName = vaName
        self.vaURL = vaURL
        
        super.init(charID: charID, name: name, imageURL: imageURL, charURL: charURL, favorites: favorites)
    }
    
    // MARK: - Codable
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnimeCodingKeys.self)
        animeID = try container.decode(Int.self, forKey: .animeID)
        animeName = try container.decode(String.self, forKey: .animeName)
        animeURL = try container.decode(URL.self, forKey: .animeURL)
        vaID = try container.decode(Int.self, forKey: .vaID)
        vaName = try container.decode(String.self, forKey: .vaName)
        vaURL = try container.decode(URL.self, forKey: .vaURL)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: AnimeCodingKeys.self)
        try container.encode(animeID,   forKey: .animeID)
        try container.encode(animeName, forKey: .animeName)
        try container.encode(animeURL,  forKey: .animeURL)
        try container.encode(vaID,   forKey: .vaID)
        try container.encode(vaName, forKey: .vaName)
        try container.encode(vaURL,  forKey: .vaURL)
    }
    
    // MARK: - Display
    
    override func displayInfoItems() -> [InfoItem] {
        var items = super.displayInfoItems()
        
        items.append(InfoItem(label: "Anime", value: animeName, url: nil))
        items.append(InfoItem(label: "Anime Page", value: animeURL.absoluteString.replacingOccurrences(of: "https://", with: ""), url: animeURL))
        items.append(InfoItem(label: "VA", value: vaName, url: nil))
        items.append(InfoItem(label: "VA Page", value: vaURL.absoluteString.replacingOccurrences(of: "https://", with: ""), url: vaURL))
        
        return items
    }
}
