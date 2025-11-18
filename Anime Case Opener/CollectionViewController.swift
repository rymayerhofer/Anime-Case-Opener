//
//  CollectionViewController.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 4/2/25.
//

import UIKit

class CollectionViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var collectedCharacters: [Character] = []
    private var sortedCharacters: [Character] = []
    private let collectionKey = "collectedCharacters"

    enum SortOption {
        case dateAdded
        case name
        case favorites
    }

    // MARK: - Lifecycle

    override func loadView() {
        // Create root view programmatically
        view = UIView()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(showSortOptions))
        setupCollectionView()
        loadCollectedCharacters()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCollectedCharacters()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 180)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true

        collectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: "CharacterCell")

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Data

    private func loadCollectedCharacters() {
        // Ensure this runs on main thread if Character accesses UserDefaults
        DispatchQueue.main.async {
            self.collectedCharacters = Character.getCharacters(forKey: self.collectionKey)
            self.sortedCharacters = self.collectedCharacters
            self.collectionView.reloadData()
        }
    }

    func sortCharacters(by option: SortOption) {
        switch option {
        case .dateAdded:
            sortedCharacters = collectedCharacters
        case .name:
            sortedCharacters = collectedCharacters.sorted { $0.name.lowercased() < $1.name.lowercased() }
        case .favorites:
            sortedCharacters = collectedCharacters.sorted { $0.favorites > $1.favorites }
        }
        collectionView.reloadData()
    }

    // MARK: - Actions

    @objc func showSortOptions() {
        let alert = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Date Added", style: .default, handler: { _ in
            self.sortCharacters(by: .dateAdded)
        }))
        alert.addAction(UIAlertAction(title: "Name", style: .default, handler: { _ in
            self.sortCharacters(by: .name)
        }))
        alert.addAction(UIAlertAction(title: "# of Favorites", style: .default, handler: { _ in
            self.sortCharacters(by: .favorites)
        }))

        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource / Delegate

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedCharacters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as? CharacterCollectionViewCell else {
            fatalError("Unable to dequeue CharacterCollectionViewCell")
        }
        let character = sortedCharacters[indexPath.item]
        cell.configure(with: character)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let character = sortedCharacters[indexPath.item]
        let detailVC = DetailViewController(character: character)
        if let nav = navigationController {
            nav.pushViewController(detailVC, animated: true)
        } else {
            present(detailVC, animated: true, completion: nil)
        }
    }
}
