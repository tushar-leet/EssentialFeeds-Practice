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
    private let loadingView:FeedLoadingView
    private let feedView:FeedView

    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                     tableName: "Feed",
                     bundle: Bundle(for: FeedPresenter.self),
                     comment: "Title for the feed view")
    }

    init(loadingView: FeedLoadingView, feedView: FeedView) {
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    func didStartLoadingFeed(){
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in self?.didStartLoadingFeed() }
        }
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed:[FeedImage]){
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in self?.didFinishLoadingFeed(with: feed) }
        }
        feedView.display(FeedViewsModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with error:Error){
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in self?.didFinishLoadingFeed(with: error) }
        }
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
