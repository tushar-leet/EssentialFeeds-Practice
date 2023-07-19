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
         let presenter = FeedPresenter(feedLoader: feedLoader)
        // let viewModel = FeedViewModel(feedLoader: feedLoader)
         let refreshController = FeedRefreshViewController(presenter: presenter)
         let feedController = FeedViewController(refreshController: refreshController)
         presenter.loadingView = WeakRefVirtualProxy(object: refreshController)
         presenter.feedView = FeedViewAdapter(controller: feedController,loader: imageLoader)
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
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

private final class FeedViewAdapter:FeedView{

    private weak var controller:FeedViewController?
    private let loader:FeedImageDataLoader
    
    init(controller: FeedViewController? = nil, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }

    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map { model in
            FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
        }
    }
}
