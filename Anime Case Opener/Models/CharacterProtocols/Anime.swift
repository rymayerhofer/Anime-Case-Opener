//
//  Anime.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/19/25.
//

import Foundation

protocol Anime {
    
    var animeID: Int { get set }
    var animeName: String { get set }
    var animeURL: URL { get set }
    var vaID: Int { get set }
    var vaName: String { get set }
    var vaURL: URL { get set }
    
}

enum AnimeCodingKeys: String, CodingKey {
    case animeID, animeName, animeURL, vaID, vaName, vaURL
}
