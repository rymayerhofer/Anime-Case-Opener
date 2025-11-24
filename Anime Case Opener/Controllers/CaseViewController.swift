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

    private let delayBeforeAnimation: TimeInterval = 0.4
    private let delayBeforeTransition: TimeInterval = 0.45

    private let animationService = CaseAnimationService()

    // MARK: - Lifecycle (same as before)
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
        audioPlayer = AVAudioPlayer.playSound(named: "sound_ui_panorama_case_unlock_01.wav")

        Task { [weak self] in
            guard let self = self else { return }

            let storage = CharacterStorage.shared
            let claimed = await storage.RandomUnowned(markAsOwned: true)

            guard let character = claimed else {
                await MainActor.run {
                    print("[openCase] No unowned character available to claim.")
                    let alert = UIAlertController(title: "No Characters", message: "There are no unowned characters available right now.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    if let nav = self.navigationController {
                        nav.present(alert, animated: true)
                    } else {
                        self.present(alert, animated: true)
                    }
                }
                return
            }

            try? await Task.sleep(nanoseconds: UInt64(self.delayBeforeAnimation * 1_000_000_000))

            await self.animationService.animateOpen(on: self.imageView)

            try? await Task.sleep(nanoseconds: UInt64(self.delayBeforeTransition * 1_000_000_000))

            await MainActor.run {
                self.audioPlayer = AVAudioPlayer.playSound(
                    named: character.favorites < 10000
                        ? "sound_ui_panorama_case_reveal_rare_01.wav"
                        : "sound_ui_panorama_case_reveal_ancient_01.wav"
                )

                let detailVC = DetailViewController(character: character)
                if let nav = self.navigationController {
                    nav.pushViewController(detailVC, animated: true)
                } else {
                    self.present(detailVC, animated: true, completion: nil)
                }
            }
        }
    }
}
