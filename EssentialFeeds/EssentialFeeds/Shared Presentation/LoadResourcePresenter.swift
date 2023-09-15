//
//  LoadResourcePresenter.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 16/09/23.
//

import Foundation

public final class LoadResourcePresenter{
    private let errorView: FeedErrorView
    private let loadingView:FeedLoadingView
    private let feedView:FeedView
    
    public init(errorView: FeedErrorView,
         loadingView:FeedLoadingView,
         feedView:FeedView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed:[FeedImage]){
        feedView.display(FeedViewsModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error:Error){
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
