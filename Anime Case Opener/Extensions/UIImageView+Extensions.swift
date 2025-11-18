//
//  UIImageView+Extensions.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 4/9/25.
//

import UIKit

extension UIImageView {
    // Asynchronously load an image from URL.
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}
