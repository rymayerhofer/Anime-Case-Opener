//
//  UIImageView+Extensions.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 4/9/25.
//

import UIKit
import Nuke

private var nukeTaskKey: UInt8 = 0

extension UIImageView {

    private var nukeTask: ImageTask? {
        get { objc_getAssociatedObject(self, &nukeTaskKey) as? ImageTask }
        set { objc_setAssociatedObject(self, &nukeTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func nukeSetImage(
        with url: URL?,
        placeholder: UIImage? = nil,
        contentMode: UIView.ContentMode = .scaleAspectFit
    ) {
        nukeTask?.cancel()
        nukeTask = nil

        self.image = placeholder
        self.contentMode = contentMode

        guard let url = url else { return }

        let request = ImageRequest(url: url)

        nukeTask = ImagePipeline.shared.loadImage(with: request) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.alpha = 0
                    self.image = response.image
                    UIView.animate(withDuration: 0.25) {
                        self.alpha = 1
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    self.image = UIImage(systemName: "photo")
                    self.alpha = 1
                }
            }
        }
    }

    func nukeCancel() {
        nukeTask?.cancel()
        nukeTask = nil
    }
}
