//
//  DetailViewController.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 4/2/25.
//

import UIKit

class DetailViewController: UIViewController {
    
    var character: Character!
    
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var vaNameLabel: UILabel!
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard character != nil else {
            print("❌ character not set!")
            return
        }

        title = "Character Details"
        view.backgroundColor = .systemBackground
        displayCharacterDetails()
    }
    
    private func displayCharacterDetails() {
        nameLabel.text = "Name: \(character.name)"
        titleLabel.text = "Title: \(character.title)"
        favoritesLabel.text = "Favorites: \(character.favorites)"
        vaNameLabel.text = "VA: \(character.vaName ?? "n/a")"
        characterImageView.load(url: character.imageURL)
    }

}
