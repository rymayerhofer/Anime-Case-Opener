//
//  CharacterStorage.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/19/25.
//

import Foundation

actor CharacterStorage {

    static let shared = CharacterStorage()

    private let unownedKey = "unownedCharacters"
    private let ownedKey = "ownedCharacters"
    private let defaults = UserDefaults.standard

    private var unownedCache: [Character]?
    private var ownedCache: [Character]?

    init() {}

    // MARK: - Persistence

    private func persistUnowned(_ chars: [Character]) {
        do {
            let wrapped = chars.map { AnyCharacter($0) }
            let data = try JSONEncoder().encode(wrapped)
            defaults.set(data, forKey: unownedKey)
            unownedCache = chars
            print("[Storage] persisted unowned (\(chars.count))")
        } catch {
            print("[Storage] failed to persist unowned:", error)
        }
    }

    private func persistOwned(_ chars: [Character]) {
        do {
            let wrapped = chars.map { AnyCharacter($0) }
            let data = try JSONEncoder().encode(wrapped)
            defaults.set(data, forKey: ownedKey)
            ownedCache = chars
            print("[Storage] persisted owned (\(chars.count))")
        } catch {
            print("[Storage] failed to persist owned:", error)
        }
    }

    private func loadUnownedFromDefaults() -> [Character] {
        if let cached = unownedCache { return cached }
        guard let data = defaults.data(forKey: unownedKey) else { return [] }

        do {
            let wrapped = try JSONDecoder().decode([AnyCharacter].self, from: data)
            let chars = wrapped.map { $0.character }
            unownedCache = chars
            return chars
        } catch {
            print("[Storage] failed to decode unowned:", error)
            return []
        }
    }

    private func loadOwnedFromDefaults() -> [Character] {
        if let cached = ownedCache { return cached }
        guard let data = defaults.data(forKey: ownedKey) else { return [] }

        do {
            let wrapped = try JSONDecoder().decode([AnyCharacter].self, from: data)
            let chars = wrapped.map { $0.character }
            ownedCache = chars
            return chars
        } catch {
            print("[Storage] failed to decode owned:", error)
            return []
        }
    }

    // MARK: - Public

    func saveUnowned(_ chars: [Character]) {
        persistUnowned(chars)
    }

    func loadUnowned() -> [Character] {
        return loadUnownedFromDefaults()
    }

    func appendToUnowned(_ char: Character) {
        var unowned = loadUnownedFromDefaults()
        if !unowned.contains(where: { $0.charID == char.charID }) {
            unowned.append(char)
            persistUnowned(unowned)
            print("[Storage] appended to unowned: \(char.name) (\(char.charID))")
        } else {
            print("[Storage] append skipped (already in unowned): \(char.charID)")
        }
    }

    func saveOwned(_ chars: [Character]) {
        persistOwned(chars)
    }

    func loadOwned() -> [Character] {
        return loadOwnedFromDefaults()
    }

    func addOwned(_ char: Character) {
        var owned = loadOwnedFromDefaults()
        if !owned.contains(where: { $0.charID == char.charID }) {
            owned.append(char)
            persistOwned(owned)
            print("[Storage] added to owned: \(char.name) (\(char.charID))")
        } else {
            print("[Storage] addOwned skipped (already owned): \(char.charID)")
        }
    }

    func RandomUnowned(markAsOwned: Bool = false) -> Character? {
        var unowned = loadUnownedFromDefaults()
        var owned = loadOwnedFromDefaults()
        let ownedIds = Set(owned.map { $0.charID })
        let unownedChar = unowned.filter { !ownedIds.contains($0.charID) }

        guard let chosen = unownedChar.randomElement() else {
            print("[Storage] claimRandomUnowned -> nil (no unowned in unowned)")
            return nil
        }

        unowned.removeAll { $0.charID == chosen.charID }

        if markAsOwned {
            if !owned.contains(where: { $0.charID == chosen.charID }) {
                owned.append(chosen)
            }
            persistUnowned(unowned)
            persistOwned(owned)
            print("[Storage] claimed and marked as owned: \(chosen.name) (\(chosen.charID))")
        } else {
            persistUnowned(unowned)
            print("[Storage] claimed (removed from unowned) but NOT marked owned: \(chosen.name) (\(chosen.charID))")
        }

        return chosen
    }
    
    func isStored(_ id: Int) -> Bool {
        let unowned = loadUnownedFromDefaults()
        if unowned.contains(where: { $0.charID == id }) {
            return true
        }

        let owned = loadOwnedFromDefaults()
        return owned.contains(where: { $0.charID == id })
    }

}

