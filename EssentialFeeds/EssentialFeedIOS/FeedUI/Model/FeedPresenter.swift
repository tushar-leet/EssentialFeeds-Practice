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

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter{
    private let loadingView:FeedLoadingView
    private let feedView:FeedView
    private let errorView: FeedErrorView

    static var title: String {
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
    
    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed:[FeedImage]){
        feedView.display(FeedViewsModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with error:Error){
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
