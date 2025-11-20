//
//  Character.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 4/2/25.
//

import Foundation

class Character: Codable {
    
    let charID: Int
    let name: String
    let imageURL: URL
    let charURL: URL
    let favorites: Int
    
    init(charID: Int, name: String, imageURL: URL, charURL: URL, favorites: Int) {
        self.charID = charID
        self.name = name
        self.imageURL = imageURL
        self.charURL = charURL
        self.favorites = favorites
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case charID, name, imageURL, charURL, favorites
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        charID = try container.decode(Int.self, forKey: .charID)
        name = try container.decode(String.self, forKey: .name)
        imageURL = try container.decode(URL.self, forKey: .imageURL)
        charURL = try container.decode(URL.self, forKey: .charURL)
        favorites = try container.decode(Int.self, forKey: .favorites)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(charID, forKey: .charID)
        try container.encode(name, forKey: .name)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(charURL, forKey: .charURL)
        try container.encode(favorites, forKey: .favorites)
    }
    
    // MARK: - Display
    
    func displayInfoItems() -> [InfoItem] {
        [
            InfoItem(label: "Name", value: name, url: nil),
            InfoItem(label: "Favorites", value: "\(favorites)", url: nil),
            InfoItem(label: "Character Page", value: charURL.absoluteString.replacingOccurrences(of: "https://", with: ""), url: charURL)
        ]
    }
}
