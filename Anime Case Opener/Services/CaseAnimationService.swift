//
//  CaseAnimationService.swift
//  Anime Case Opener
//
//  Created by Ryan Mayerhofer on 11/24/25.
//

import UIKit

@MainActor
final class CaseAnimationService {

    var shakeDuration: TimeInterval = 0.45
    var shineDuration: TimeInterval = 0.48
    var popDuration: TimeInterval = 0.32
    var popBounceDelay: TimeInterval = 0.06
    var postPopHold: TimeInterval = 0.14

    init() {}

    func animateOpen(on imageView: UIImageView) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            animateOpen(on: imageView) {
                continuation.resume()
            }
        }
    }

    func animateOpen(on imageView: UIImageView, completion: @escaping () -> Void) {
        imageView.superview?.layoutIfNeeded()

        let shakeDuration = self.shakeDuration
        let shineDuration = self.shineDuration
        let popDuration = self.popDuration
        let popBounceDelay = self.popBounceDelay
        let postPopHold = self.postPopHold

        let originalTransform = imageView.transform

        UIView.animateKeyframes(withDuration: shakeDuration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.18) {
                imageView.transform = CGAffineTransform(translationX: -14, y: 0).rotated(by: -0.04)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.18, relativeDuration: 0.32) {
                imageView.transform = CGAffineTransform(translationX: 20, y: 0).rotated(by: 0.06)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.50, relativeDuration: 0.25) {
                imageView.transform = CGAffineTransform(translationX: -8, y: 0).rotated(by: -0.03)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                imageView.transform = originalTransform
            }
        }, completion: { _ in

            Task { @MainActor in
                self.addShine(to: imageView, duration: shineDuration)

                UIView.animate(withDuration: popDuration,
                               delay: popBounceDelay,
                               usingSpringWithDamping: 0.58,
                               initialSpringVelocity: 1.6,
                               options: [.curveEaseOut],
                               animations: {
                    imageView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.18, animations: {
                        imageView.transform = .identity
                    }, completion: { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + postPopHold) {
                            completion()
                        }
                    })
                })
            }
        })
    }

    private func addShine(to imageView: UIImageView, duration: TimeInterval) {
        imageView.layer.sublayers?.removeAll(where: { $0.name == "case_shine_layer" })

        let shineLayer = CAGradientLayer()
        shineLayer.name = "case_shine_layer"
        shineLayer.frame = imageView.bounds.insetBy(dx: -imageView.bounds.width, dy: 0)
        shineLayer.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.45).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        shineLayer.locations = [0.0, 0.5, 1.0]
        shineLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        shineLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        shineLayer.transform = CATransform3DMakeRotation(-0.45, 0, 0, 1)

        imageView.layer.addSublayer(shineLayer)

        let slide = CABasicAnimation(keyPath: "position.x")
        slide.fromValue = -imageView.bounds.width
        slide.toValue = imageView.bounds.width * 2
        slide.duration = duration
        slide.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        slide.fillMode = .forwards
        slide.isRemovedOnCompletion = true

        shineLayer.add(slide, forKey: "case_shine_slide")

        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.08) {
            shineLayer.removeFromSuperlayer()
        }
    }
}
