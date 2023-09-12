//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by TUSHAR SHARMA on 09/08/23.
//

import UIKit
import EssentialFeeds
import EssentialFeedIOS
import Combine
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
             LocalFeedLoader(store: store, currentDate: Date.init)
         }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite"))
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene:scene)
        configureWindow()
    }
    
    func configureWindow() {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: makeRemoteFeedLoaderWithLocalFallBack, imageLoader: FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader, fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader)))
        window?.rootViewController = UINavigationController(rootViewController: feedViewController)
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
             localFeedLoader.validateCache { _ in }
         }
    
    private func makeRemoteFeedLoaderWithLocalFallBack() -> AnyPublisher<[FeedImage],Error>{
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        return remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
        
    }
}

public extension FeedLoader{
    typealias Publisher = AnyPublisher<[FeedImage],Swift.Error>
     func loadPublisher() -> Publisher{
        return Deferred{
            Future(self.load)
        }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedImage]{
    func caching(to cache:FeedCache) -> AnyPublisher<Output,Failure>{
        handleEvents(receiveOutput:cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

extension Publisher{
    func fallback(to fallbackPublisher:@escaping () -> AnyPublisher<Output,Failure>) -> AnyPublisher<Output,Failure>{
        self.catch{_ in fallbackPublisher()}.eraseToAnyPublisher()
    }
}

extension Publisher{
    func dispatchOnMainQueue() -> AnyPublisher<Output,Failure>{
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {

     static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
         ImmediateWhenOnMainQueueScheduler()
     }

     struct ImmediateWhenOnMainQueueScheduler: Scheduler {
         typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
         typealias SchedulerOptions = DispatchQueue.SchedulerOptions

         var now: SchedulerTimeType {
             DispatchQueue.main.now
         }

         var minimumTolerance: SchedulerTimeType.Stride {
             DispatchQueue.main.minimumTolerance
         }

         func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
             guard Thread.isMainThread else {
                 return DispatchQueue.main.schedule(options: options, action)
             }

             action()
         }

         func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
             DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
         }

         func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
             DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
         }
     }
 }

