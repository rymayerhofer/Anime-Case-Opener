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
    private let infoStack = UIStackView()
    
    private static var linkURLKey: UInt8 = 0
    
    init(character: Character) {
        self.character = character
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        
        infoStack.axis = .vertical
        infoStack.spacing = 8
        infoStack.alignment = .fill
        
        stackView.addArrangedSubview(characterImageView)
        stackView.addArrangedSubview(infoStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),
            
            characterImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 400)
        ])
        
        characterImageView.contentMode = .scaleAspectFit
        characterImageView.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Character Details"
        renderCharacter()
    }
    
    private func renderCharacter() {
        let placeholder = UIImage(systemName: "person.crop.square")
        characterImageView.nukeSetImage(with: character.imageURL, placeholder: placeholder, contentMode: .scaleAspectFit)
        
        infoStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in character.displayInfoItems() {
            let itemStack = UIStackView()
            itemStack.axis = .vertical
            itemStack.spacing = 2
            itemStack.alignment = .fill

            let keyLabel = UILabel()
            keyLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            keyLabel.text = "\(item.label):"
            keyLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

            let valueLabel = UILabel()
            valueLabel.font = .systemFont(ofSize: 16)
            valueLabel.text = item.value
            valueLabel.textColor = item.url != nil ? .systemBlue : .label
            valueLabel.isUserInteractionEnabled = item.url != nil
            
            if let url = item.url {
                let tap = UITapGestureRecognizer(target: self, action: #selector(linkTapped(_:)))
                valueLabel.addGestureRecognizer(tap)
                objc_setAssociatedObject(valueLabel, &Self.linkURLKey, url, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            itemStack.addArrangedSubview(keyLabel)
            itemStack.addArrangedSubview(valueLabel)
            infoStack.addArrangedSubview(itemStack)
        }
    }
    
    @objc private func linkTapped(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel,
              let url = objc_getAssociatedObject(label, &Self.linkURLKey) as? URL else { return }
        UIApplication.shared.open(url)
    }
}
