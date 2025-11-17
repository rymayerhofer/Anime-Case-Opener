//
//  CaseViewController.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 4/2/25.
//

import UIKit
import AVFoundation

class CasesViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var audioPlayer: AVAudioPlayer?
    
    // Key to store collected characters in UserDefaults.
    private let collectionKey = "collectedCharacters"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openCase))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func openCase() {
        playSound(named: "sound_ui_panorama_case_unlock_01.wav")
        
        //TODO: improve animation
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.imageView.transform = CGAffineTransform.identity
            }
        })
        
        Character.fetchRandomCharacter { [weak self] character in
            guard let character = character else { return }
            
            // Save the character to collection.
            var currentCollection = Character.getCharacters(forKey: self?.collectionKey ?? "")
            // Avoid duplicates.
            if !currentCollection.contains(where: { $0.charID == character.charID }) {
                currentCollection.append(character)
                Character.save(currentCollection, forKey: self?.collectionKey ?? "")
            }
            
            print("✅ Attempting to perform segue to detail with character: \(character.name)")
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                if character.favorites < 1000 {
                    self.playSound(named: "sound_ui_panorama_case_reveal_rare_01.wav")
                } else {
                    self.playSound(named: "sound_ui_panorama_case_reveal_ancient_01.wav")
                }
                self.performSegue(withIdentifier: "showDetail", sender: character)
            }
        }
    }
    
    private func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: nil) else {
            print("Sound file \(soundName) not found!")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing sound:", error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
           let detailVC = segue.destination as? DetailViewController,
           let character = sender as? Character {
            detailVC.character = character
        }
    }
}
