//
//  FeedPresenter.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 07/07/23.
//

import EssentialFeeds

protocol FeedView{
    func display(feed:[FeedImage])
}

protocol FeedLoadingView:AnyObject{
    func display(isLoading:Bool)
}

final class FeedPresenter{
    private let feedLoader: FeedLoader
    typealias Observer<T> = ((T) -> Void)

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    weak var loadingView:FeedLoadingView?
    var feedView:FeedView?
    
    
    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
