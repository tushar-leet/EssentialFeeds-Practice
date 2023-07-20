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

    init(loadingView: FeedLoadingView, feedView: FeedView) {
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    func didStartLoadingFeed(){
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed:[FeedImage]){
        feedView.display(FeedViewsModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with error:Error){
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
