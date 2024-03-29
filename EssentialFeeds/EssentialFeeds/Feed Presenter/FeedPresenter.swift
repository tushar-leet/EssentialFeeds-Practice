//
//  FeedPresenter.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 02/08/23.
//

import Foundation

public protocol FeedView{
    func display(_ viewModel:FeedViewsModel)
}

public final class FeedPresenter {
    
    private let errorView: ResourceErrorView
    private let loadingView:ResourceLoadingView
    private let feedView:FeedView
    
    public init(errorView: ResourceErrorView,
         loadingView:ResourceLoadingView,
         feedView:FeedView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed:[FeedImage]){
        feedView.display(Self.map(feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error:Error){
        errorView.display(.error(message: feedLoadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public static func map(_ feed:[FeedImage]) -> FeedViewsModel{
        FeedViewsModel(feed: feed)
    }
}
