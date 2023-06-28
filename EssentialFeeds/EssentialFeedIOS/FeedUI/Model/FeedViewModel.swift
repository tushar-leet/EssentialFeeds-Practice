//
//  FeedViewModel.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 28/06/23.
//

import EssentialFeeds

final class FeedViewModel{
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onChange:((FeedViewModel) -> ())?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    private(set) var isLoading:Bool = false{
        didSet{
            onChange?(self)
        }
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
