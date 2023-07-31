//
//  UIView+Animation.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 22/07/23.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage

        guard newImage != nil else { return }

        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
