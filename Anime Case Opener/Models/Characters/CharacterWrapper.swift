//
//  CharacterWrapper.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/20/25.
//

import Foundation

/// Dynamic wrapper to preserve subclass type when encoding/decoding
struct AnyCharacter: Codable {
    let character: Character

    init(_ character: Character) {
        self.character = character
    }

    private enum CodingKeys: String, CodingKey {
        case type, payload
    }

    /// Encode: store the runtime class name + encoded payload
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let typeName = NSStringFromClass(type(of: character))
        try container.encode(typeName, forKey: .type)

        let payloadData = try JSONEncoder().encode(character)
        try container.encode(payloadData, forKey: .payload)
    }

    /// Decode: reconstruct the subclass dynamically from its class name
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .type)
        let payloadData = try container.decode(Data.self, forKey: .payload)

        if let cls = NSClassFromString(typeName) as? Character.Type {
            character = try JSONDecoder().decode(cls, from: payloadData)
        } else {
            character = try JSONDecoder().decode(Character.self, from: payloadData)
        }
    }
}

