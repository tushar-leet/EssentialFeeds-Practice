//
//  FeedImageCell.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 16/06/23.
//

import Foundation
import UIKit

public class FeedImageCell:UITableViewCell{
    @IBOutlet private(set) public var locationContainer: UIView!
         @IBOutlet private(set) public var locationLabel: UILabel!
         @IBOutlet private(set) public var feedImageContainer: UIView!
         @IBOutlet private(set) public var feedImageView: UIImageView!
         @IBOutlet private(set) public var feedImageRetryButton: UIButton!
         @IBOutlet private(set) public var descriptionLabel: UILabel!

    var onRetry: (() -> Void)?

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
