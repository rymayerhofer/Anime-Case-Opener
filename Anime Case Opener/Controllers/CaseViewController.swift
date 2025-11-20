//
//  CaseViewController.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 4/2/25.
//

import UIKit
import AVFoundation

final class CasesViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.accessibilityIdentifier = "caseImageView"
        return iv
    }()

    private var audioPlayer: AVAudioPlayer?
    private let collectionKey = "collectedCharacters"

    // MARK: - Lifecycle

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(openCase))
        imageView.addGestureRecognizer(tap)
    }

    private func setupUI() {
        view.addSubview(imageView)
        imageView.image = UIImage(named: "cs case")

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 301),
            imageView.heightAnchor.constraint(equalToConstant: 223)
        ])
    }

    // MARK: - Actions

    @objc private func openCase() {
        playSound(named: "sound_ui_panorama_case_unlock_01.wav")

        Task { [weak self] in
            guard let self = self else { return }

            let storage = CharacterStorage.shared

            let claimed = await storage.RandomUnowned(markAsOwned: true)

            await MainActor.run {
                guard let character = claimed else {
                    print("[openCase] No unowned character available to claim.")
                    let alert = UIAlertController(title: "No Characters", message: "There are no unowned characters available right now.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    if let nav = self.navigationController {
                        nav.present(alert, animated: true)
                    } else {
                        self.present(alert, animated: true)
                    }
                    return
                }

                if character.favorites < 10000 {
                    self.playSound(named: "sound_ui_panorama_case_reveal_rare_01.wav")
                } else {
                    self.playSound(named: "sound_ui_panorama_case_reveal_ancient_01.wav")
                }

                let detailVC = DetailViewController(character: character)
                if let nav = self.navigationController {
                    nav.pushViewController(detailVC, animated: true)
                } else {
                    self.present(detailVC, animated: true, completion: nil)
                }
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
}
