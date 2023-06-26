//
//  FeedImageCell.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 16/06/23.
//

import Foundation
import UIKit

public class FeedImageCell:UITableViewCell{
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()

    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?

    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
