//
//  JikanAPIService.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/19/25.
//

import Foundation

final class JikanAPIService {
    
    static let shared = JikanAPIService()

    enum ServiceError: Error, Equatable {
        case invalidURL
        case rateLimited
        case httpError(statusCode: Int)
        case unknown
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchTopPage(page: Int, limit: Int) async throws -> Data {
        print("[API Service] Fetching top")
        guard let url = URL(string: "https://api.jikan.moe/v4/top/characters?page=\(page)&limit=\(limit)") else {
            throw ServiceError.invalidURL
        }
        let (data, response) = try await session.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200:
                return data
            case 429:
                throw ServiceError.rateLimited
            default:
                throw ServiceError.httpError(statusCode: httpResponse.statusCode)
            }
        } else {
            throw ServiceError.unknown
        }
    }

    func fetchVoices(forCharacterID id: Int) async throws -> Data {
        print("[API Service] Fetching voice for: " + String(id))
        guard let url = URL(string: "https://api.jikan.moe/v4/characters/\(id)/voices") else {
            throw ServiceError.invalidURL
        }
        let (data, response) = try await session.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200:
                return data
            case 429:
                throw ServiceError.rateLimited
            default:
                throw ServiceError.httpError(statusCode: httpResponse.statusCode)
            }
        } else {
            throw ServiceError.unknown
        }
    }
    
    func fetchAnime(forCharacterID id: Int) async throws -> Data {
        print("[API Service] Fetching anime for: " + String(id))
        guard let url = URL(string: "https://api.jikan.moe/v4/characters/\(id)/anime") else {
            throw ServiceError.invalidURL
        }
        let (data, response) = try await session.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200:
                return data
            case 429:
                throw ServiceError.rateLimited
            default:
                throw ServiceError.httpError(statusCode: httpResponse.statusCode)
            }
        } else {
            throw ServiceError.unknown
        }
    }
    
    func fetchManga(forCharacterID id: Int) async throws -> Data {
        print("[API Service] Fetching manga for: " + String(id))
        guard let url = URL(string: "https://api.jikan.moe/v4/characters/\(id)/manga") else {
            throw ServiceError.invalidURL
        }
        let (data, response) = try await session.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200:
                return data
            case 429:
                throw ServiceError.rateLimited
            default:
                throw ServiceError.httpError(statusCode: httpResponse.statusCode)
            }
        } else {
            throw ServiceError.unknown
        }
    }
}
