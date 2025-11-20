//
//  Manga.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/19/25.
//

import Foundation

protocol Manga {
    
    var mangaID: Int { get set }
    var mangaName: String { get set }
    var mangaURL: URL { get set }
    
}

enum MangaCodingKeys: String, CodingKey {
    case mangaID, mangaName, mangaURL
}
