//
//  AVAudioPlauer+Extensions.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/24/25.
//

import AVFoundation

extension AVAudioPlayer {
    @discardableResult
    static func playSound(named name: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            print("Sound file \(name) not found!")
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            return player
        } catch {
            print("Error playing sound:", error)
            return nil
        }
    }
}
