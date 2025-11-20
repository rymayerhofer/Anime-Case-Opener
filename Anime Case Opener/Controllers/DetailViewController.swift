//
//  DetailViewController.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 4/2/25.
//

import UIKit
import Foundation

struct InfoItem {
    let label: String
    let value: String
    let url: URL?
}

final class DetailViewController: UIViewController {
    
    private let character: Character

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let characterImageView = UIImageView()
    private let nameLabel = UILabel()
    private let titleLabel = UILabel()
    private let favoritesLabel = UILabel()
    private let vaNameLabel = UILabel()

    // MARK: - Init

    init(character: Character) {
        self.character = character
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported. Use init(character:).")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        // Build hierarchy: scrollView -> contentView -> stackView -> arrangedSubviews
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            // scrollView fills safe area
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // contentView pinned to scrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            // contentView width = view width
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),

            // stackView pinned inside contentView with margins
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Character Details"
        configureViews()
        displayCharacterDetails()
    }

    // MARK: - View Configuration

    private func configureViews() {
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill

        characterImageView.contentMode = .scaleAspectFit
        characterImageView.clipsToBounds = true
        characterImageView.translatesAutoresizingMaskIntoConstraints = false

        let imageAspect = characterImageView.widthAnchor.constraint(equalTo: characterImageView.heightAnchor, multiplier: 1.0)
        imageAspect.priority = .required
        imageAspect.isActive = true

        characterImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true

        nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.numberOfLines = 0

        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.numberOfLines = 0

        favoritesLabel.font = .systemFont(ofSize: 18)
        favoritesLabel.numberOfLines = 0

        vaNameLabel.font = .systemFont(ofSize: 18)
        vaNameLabel.numberOfLines = 0

        stackView.addArrangedSubview(characterImageView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(favoritesLabel)
        stackView.addArrangedSubview(vaNameLabel)
    }

    private func displayCharacterDetails() {
        nameLabel.text = "Name: \(character.name)"
        titleLabel.text = "Title: \(character.title)"
        favoritesLabel.text = "Favorites: \(character.favorites)"
        vaNameLabel.text = "VA: \(character.vaName ?? "n/a")"

        // Load image (assumes you have the same UIImageView extension)
        // Ensure UI update happens on main if load(url:) uses background thread
        characterImageView.load(url: character.imageURL)
    }
}
