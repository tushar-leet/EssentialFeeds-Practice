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

public extension Paginated {
     var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
         guard let loadMore = loadMore else { return nil }

         return {
             Deferred {
                 Future(loadMore)
             }.eraseToAnyPublisher()
         }
     }
 }


public final class FeedUIComposer {
     private init() {}

    public static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
                                        imageLoader:  @escaping (URL) -> FeedImageDataLoader.Publisher,
                                        selection: @escaping (FeedImage) -> Void = { _ in }) -> ListViewController {
         
        let presentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>,FeedViewAdapter>(loader: feedLoader)
         let feedController = ListViewController.makeWith(
                      title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        presentationAdapter.presenter = LoadResourcePresenter(errorView: WeakRefVirtualProxy(object: feedController), loadingView: WeakRefVirtualProxy(object: feedController), resourceView: FeedViewAdapter(controller: feedController,loader: imageLoader, selection: selection), mapper: {$0})
         return feedController
     }
 }

private extension ListViewController {
     static func makeWith(title: String) -> ListViewController {
         let bundle = Bundle(for: ListViewController.self)
         let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
         let feedController = storyboard.instantiateInitialViewController() as! ListViewController
         feedController.title = title
         return feedController
     }
 }

 final class WeakRefVirtualProxy<T:AnyObject>{
    private weak var object:T?
    
    init(object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy:ResourceLoadingView where T:ResourceLoadingView{
    func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceView where T: ResourceView, T.ResourceViewModel == UIImage {
     func display(_ model: UIImage) {
         object?.display(model)
     }
 }

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
    func display(_ viewModel: EssentialFeeds.ResourceErrorViewModel) {
        object?.display(viewModel)
    }
 }

private final class FeedViewAdapter:ResourceView{

    private weak var controller:ListViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    private let selection: (FeedImage) -> Void
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>,FeedViewAdapter>
    init(controller: ListViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher,selection: @escaping (FeedImage) -> Void) {
        self.controller = controller
        self.loader = loader
        self.selection = selection
    }

    func display(_ viewModel: Paginated<FeedImage>) {
        let feed:[CellController] = viewModel.items.map { model in
            let adapter = LoadResourcePresentationAdapter<Data,WeakRefVirtualProxy<FeedImageCellController>>(loader:{ [loader] in
                loader(model.url)
            })
            let view = FeedImageCellController(viewModel:FeedImagePresenter.map(model),delegate: adapter, selection: { [selection] in
                selection(model)
            })
            
            adapter.presenter = LoadResourcePresenter(errorView: WeakRefVirtualProxy(object: view),
                                                      loadingView: WeakRefVirtualProxy(object: view),
                                                      resourceView: WeakRefVirtualProxy(object: view),
                                                      mapper: UIImage.tryMake)
            
            return CellController(id:model,view)
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller?.display(feed)
            return
        }

        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(errorView: WeakRefVirtualProxy(object: loadMore),
                                                          loadingView: WeakRefVirtualProxy(object: loadMore),
                                                          resourceView: self,
                                                          mapper: {$0})
        let loadMoreSection = [CellController(id:UUID() ,loadMore)]
        
        controller?.display(feed, loadMoreSection)
    }
}

 final class LoadResourcePresentationAdapter<Resource,View:ResourceView> {
     private let loader: () ->  AnyPublisher<Resource,Error>
     var presenter: LoadResourcePresenter<Resource,View>?
    private var cancellable:Cancellable?

    init(loader: @escaping () -> AnyPublisher<Resource,Error>) {
         self.loader = loader
     }

    func loadResource() {
         presenter?.didStartLoading()

        cancellable = loader()
            .dispatchOnMainQueue()
            .sink { [weak self] completion in
            switch completion{
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        } receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoading(with: feed)
        }
     }
 }

extension UIImage {
     struct InvalidImageData: Error {}

     static func tryMake(data: Data) throws -> UIImage {
         guard let image = UIImage(data: data) else {
             throw InvalidImageData()
         }
         return image
     }
 }

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
     func didRequestImage() {
         loadResource()
     }

     func didCancelImageRequest() {
         cancellable?.cancel()
         cancellable = nil
     }
 }

/*
private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        cancellable = imageLoader(model.url)
            .dispatchOnMainQueue()
            .sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                    
                case let .failure(error):
                    self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                }
                
            }, receiveValue: { [weak self] data in
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            })
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
*/
