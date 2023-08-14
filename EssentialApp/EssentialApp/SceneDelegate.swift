//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by TUSHAR SHARMA on 09/08/23.
//

import UIKit
import EssentialFeeds
import EssentialFeedIOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        
        let localStoreUrl = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
               let localStore = try! CoreDataFeedStore(storeURL: localStoreUrl)
               let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
               let localImageLoader = LocalFeedImageDataLoader(store: localStore)

               let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: FeedLoaderWithFallbackComposite(primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader), fallback: localFeedLoader), imageLoader: FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader, fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader)))
        window?.rootViewController = feedViewController

    }
    
    private func makeRemoteClient() -> HTTPClient {
        switch UserDefaults.standard.string(forKey: "connectivity") {
        case "offline":
            return AlwaysFailingHTTPClient()
            
        default:
            return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        }
    }
}

private class AlwaysFailingHTTPClient: HTTPClient {
     private class Task: HTTPClientTask {
         func cancel() {}
     }

     func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
         completion(.failure(NSError(domain: "offline", code: 0)))
         return Task()
     }
 }
