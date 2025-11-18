//
//  Character.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 4/2/25.
//

import Foundation

struct Character: Codable {
    
    let charID: Int
    let name: String
    let title: String
    let imageURL: URL
    let charURL: URL
    let favorites: Int
    let vaID: Int?
    let vaName: String?
    let vaURL: URL?
    
    // Define CodingKeys to map JSON keys from the Jikan API
    enum CodingKeys: String, CodingKey {
        case charID = "mal_id"
        case charURL = "url"
        case imageURL = "images"
        case name
        case favorites
        case anime
        case manga
        case voiceActors = "voices"
    }
    
    // Custom initializer to decode JSON from the Jikan API v4
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Map the API's mal_id to charID
        self.charID = try container.decode(Int.self, forKey: .charID)
        
        // Assign the character URL
        self.charURL = try container.decode(URL.self, forKey: .charURL)
        
        // Decode the name and favorites count
        self.name = try container.decode(String.self, forKey: .name)
        self.favorites = try container.decode(Int.self, forKey: .favorites)
        
        // Decode image_url from the images structure
        let images = try container.decode(Images.self, forKey: .imageURL)
        self.imageURL = images.jpg.imageURL
        
        // Determine title from the first available anime or manga entry
        let animeEntries = try container.decodeIfPresent([AnimeEntry].self, forKey: .anime)
        let mangaEntries = try container.decodeIfPresent([MangaEntry].self, forKey: .manga)
        self.title = animeEntries?.first?.anime?.title
                   ?? mangaEntries?.first?.manga?.title
                   ?? "Unknown"
        
        // Decode voice actor details
        let voiceActors = try container.decodeIfPresent([VoiceActor].self, forKey: .voiceActors)
        let japaneseVA = voiceActors?.first(where: { $0.language == "Japanese" })
        self.vaID = japaneseVA?.person.mal_id
        self.vaName = japaneseVA?.person.name
        self.vaURL = japaneseVA?.person.url
    }
    
    // Method to conform to Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.charID, forKey: .charID)
        try container.encode(self.charURL, forKey: .charURL)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.favorites, forKey: .favorites)
        
        let jpg = Images.Jpg(imageURL: self.imageURL)
        let images = Images(jpg: jpg)
        try container.encode(images, forKey: .imageURL)
        
        let anime = Anime(mal_id: self.charID, title: self.title, url: self.charURL)
        let animeEntry = AnimeEntry(anime: anime)
        try container.encode([animeEntry], forKey: .anime)

        let manga = Manga(mal_id: self.charID, title: self.title, url: self.charURL)
        let mangaEntry = MangaEntry(manga: manga)
        try container.encode([mangaEntry], forKey: .manga)
        
        if let vaID = self.vaID, let vaName = self.vaName, let vaURL = self.vaURL {
            let person = Person(mal_id: vaID, name: vaName, url: vaURL)
            let voiceActorEntry = VoiceActor(person: person, language: "Japanese")
            try container.encode([voiceActorEntry], forKey: .voiceActors)
        } else {
            try container.encode([VoiceActor](), forKey: .voiceActors)
        }
    }
    
    // Nested struct for decoding the images object
    struct Images: Codable {
        let jpg: Jpg

        struct Jpg: Codable {
            let imageURL: URL

            enum CodingKeys: String, CodingKey {
                case imageURL = "image_url"
            }
        }
    }
    
    // Struct for decoding anime array objects
    struct AnimeEntry: Codable {
        let anime: Anime?
    }

    struct Anime: Codable {
        let mal_id: Int
        let title: String
        let url: URL
    }
    
    // Struct for decoding manga array objects
    struct MangaEntry: Codable {
        let manga: Manga?
    }

    struct Manga: Codable {
        let mal_id: Int
        let title: String
        let url: URL
    }
    
    // Struct for decoding voice actor details if available
    struct VoiceActor: Codable {
        let person: Person
        let language: String
    }

    struct Person: Codable {
        let mal_id: Int
        let name: String
        let url: URL
    }

}

// Response struct to match the API response structure
struct CharacterResponse: Codable {
    let data: Character
}

// Extension for fetching characters from the Jikan API v4
extension Character {
    
    static func fetchRandomCharacter(completion: @escaping (Character?) -> Void) {

        let url = URL(string: "https://api.jikan.moe/v4/random/characters")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let characterResponse = try decoder.decode(CharacterResponse.self, from: data)
                let basicCharacter = characterResponse.data
                
                if basicCharacter.favorites >= 20 {
                    // Fetch full details using character ID
                    fetchKnownCharacter(id: basicCharacter.charID, completion: completion)
                    
                } else {
                    print("⚠️ Character '\(basicCharacter.name)' is too obscure (favorites: \(basicCharacter.favorites)). Retrying...")
                    fetchRandomCharacter(completion: completion)
                }
            } catch {
                print("❌ Decoding error:", error)
                completion(nil)
            }
        }.resume()
    }

    
    static func fetchKnownCharacter(id: Int, completion: @escaping (Character?) -> Void) {
        let url = URL(string: "https://api.jikan.moe/v4/characters/\(id)/full")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let fullResponse = try decoder.decode(CharacterResponse.self, from: data)
                completion(fullResponse.data)
            } catch {
                print("❌ Decoding error in full fetch: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

// Extension for saving to and retreaving from UserDefaults
extension Character {
    
    // Save an array of Character objects to UserDefaults
    static func save(_ characters: [Character], forKey key: String) {
        let defaults = UserDefaults.standard
        let encodedData = try! JSONEncoder().encode(characters)
        defaults.set(encodedData, forKey: key)
    }
    
    // Retrieve an array of Character objects from UserDefaults
    static func getCharacters(forKey key: String) -> [Character] {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: key) {
            let decodedCharacters = try! JSONDecoder().decode([Character].self, from: data)
            return decodedCharacters
        } else {
            return []
        }
    }
}
