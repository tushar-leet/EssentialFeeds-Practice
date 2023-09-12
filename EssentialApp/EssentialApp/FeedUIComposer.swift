//
//  FeedUIComposer.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 26/06/23.
//

import EssentialFeeds
import UIKit
import Combine
import EssentialFeedIOS

public final class FeedUIComposer {
     private init() {}

    public static func feedComposedWith(feedLoader: @escaping () -> FeedLoader.Publisher, imageLoader: FeedImageDataLoader) -> FeedViewController {
         
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: {feedLoader().dispatchOnMainQueue()})
         let feedController = FeedViewController.makeWith(
                      delegate: presentationAdapter,
                      title: FeedPresenter.title)
         presentationAdapter.presenter = FeedPresenter(errorView: WeakRefVirtualProxy(object: feedController), loadingView: WeakRefVirtualProxy(object: feedController), feedView: FeedViewAdapter(controller: feedController,loader:  MainQueueDispatchDecorator(decoratee: imageLoader)))
         return feedController
     }
 }

private extension FeedViewController {
     static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
         let bundle = Bundle(for: FeedViewController.self)
         let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
         let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
         feedController.delegate = delegate
         feedController.title = title
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

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
     func display(_ model: FeedImageViewModel<UIImage>) {
         object?.display(model)
     }
 }

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: EssentialFeeds.FeedErrorViewModel) {
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
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: self.loader)
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(object: view),
                imageTransformer: UIImage.init)
            
            return view
        })
    }
}

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
     private let feedLoader: () -> FeedLoader.Publisher
     var presenter: FeedPresenter?
    private var cancellable:Cancellable?

    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
         self.feedLoader = feedLoader
     }

    func didRequestFeedRefresh() {
         presenter?.didStartLoadingFeed()

        cancellable = feedLoader().sink { [weak self] completion in
            switch completion{
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        } receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoadingFeed(with: feed)
        }
     }
 }

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
     private let model: FeedImage
     private let imageLoader: FeedImageDataLoader
     private var task: FeedImageDataLoaderTask?

     var presenter: FeedImagePresenter<View, Image>?

     init(model: FeedImage, imageLoader: FeedImageDataLoader) {
         self.model = model
         self.imageLoader = imageLoader
     }

     func didRequestImage() {
         presenter?.didStartLoadingImageData(for: model)

         let model = self.model
         task = imageLoader.loadImageData(from: model.url) { [weak self] result in
             switch result {
             case let .success(data):
                 self?.presenter?.didFinishLoadingImageData(with: data, for: model)

             case let .failure(error):
                 self?.presenter?.didFinishLoadingImageData(with: error, for: model)
             }
         }
     }

     func didCancelImageRequest() {
         task?.cancel()
     }
 }
