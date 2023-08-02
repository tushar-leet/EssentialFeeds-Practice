//
//  FeedPresenter.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 02/08/23.
//

import Foundation

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public protocol FeedLoadingView{
    func display(_ isLoading:FeedLoadingViewModel)
}

public struct FeedLoadingViewModel{
    public let isLoading:Bool
}

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

public struct FeedViewsModel{
    public let feed:[FeedImage]
}

public protocol FeedView{
    func display(_ viewModel:FeedViewsModel)
}

public final class FeedPresenter {
    
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
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
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
