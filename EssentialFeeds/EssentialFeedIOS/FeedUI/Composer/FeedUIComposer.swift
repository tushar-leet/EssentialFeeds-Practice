//
//  FeedUIComposer.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 26/06/23.
//

import EssentialFeeds
import UIKit

public final class FeedUIComposer {
     private init() {}

     public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
         
         let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
         let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
         let feedController = FeedViewController(refreshController: refreshController)
         presentationAdapter.presenter = FeedPresenter(loadingView: WeakRefVirtualProxy(object: refreshController), feedView: FeedViewAdapter(controller: feedController,loader: imageLoader))
         return feedController
     }
 }

private final class WeakRefVirtualProxy<T:AnyObject>{
    private weak var object:T?
    
    init(object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy:FeedLoadingView where T:FeedLoadingView{
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter:FeedView{

    private weak var controller:FeedViewController?
    private let loader:FeedImageDataLoader
    
    init(controller: FeedViewController? = nil, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }

    func display(_ viewModel: FeedViewsModel) {
        controller?.tableModel = viewModel.feed.map { model in
            FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
     private let feedLoader: FeedLoader
     var presenter: FeedPresenter?

     init(feedLoader: FeedLoader) {
         self.feedLoader = feedLoader
     }

    func didRequestFeedRefresh() {
         presenter?.didStartLoadingFeed()

         feedLoader.load { [weak self] result in
             switch result {
             case let .success(feed):
                 self?.presenter?.didFinishLoadingFeed(with: feed)

             case let .failure(error):
                 self?.presenter?.didFinishLoadingFeed(with: error)
             }
         }
     }
 }
