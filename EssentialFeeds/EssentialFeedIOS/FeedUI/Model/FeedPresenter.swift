//
//  FeedPresenter.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 07/07/23.
//

import EssentialFeeds

protocol FeedView{
    func display(_ viewModel:FeedViewsModel)
}

struct FeedLoadingViewModel{
    let isLoading:Bool
}

struct FeedViewsModel{
    let feed:[FeedImage]
}

protocol FeedLoadingView{
    func display(_ isLoading:FeedLoadingViewModel)
}

final class FeedPresenter{
    private let feedLoader: FeedLoader
    typealias Observer<T> = ((T) -> Void)

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var loadingView:FeedLoadingView?
    var feedView:FeedView?
    
    
    func loadFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewsModel(feed: feed))
            }
            self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
