//
//  CollectionViewController.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 4/2/25.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var collectionView: UICollectionView!
    private var collectedCharacters: [Character] = []
    private var sortedCharacters: [Character] = []
    private let collectionKey = "collectedCharacters"
    
    enum SortOption {
        case dateAdded
        case name
        case favorites
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        loadCollectedCharacters()
        title = "Character Detail"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(showSortOptions))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCollectedCharacters()
    }
    
    private func setupCollectionView() {
        // Creates grid layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 180)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Registers the custom cell.
        collectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: "CharacterCell")
        view.addSubview(collectionView)
    }
    
    private func loadCollectedCharacters() {
        collectedCharacters = Character.getCharacters(forKey: collectionKey)
        sortedCharacters = collectedCharacters
        collectionView.reloadData()
    }
    
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let character = sortedCharacters[indexPath.item]
        performSegue(withIdentifier: "showDetail", sender: character)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
           let character = sender as? Character,
           let detailVC = segue.destination as? DetailViewController {
            detailVC.character = character
        }
    }
}
