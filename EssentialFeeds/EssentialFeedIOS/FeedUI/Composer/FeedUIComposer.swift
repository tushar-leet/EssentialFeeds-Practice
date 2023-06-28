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
         let viewModel = FeedViewModel(feedLoader: feedLoader)
         let refreshController = FeedRefreshViewController(viewModel: viewModel)
         let feedController = FeedViewController(refreshController: refreshController)
         viewModel.onFeedLoad = { [weak feedController] feed in
             feedController?.tableModel = feed.map { model in
                 FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
             }
         }
         return feedController
     }

 }
