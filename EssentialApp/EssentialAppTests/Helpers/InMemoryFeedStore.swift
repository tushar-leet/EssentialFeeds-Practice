//
//  InMemoryFeedStore.swift
//  EssentialAppTests
//
//  Created by TUSHAR SHARMA on 05/09/23.
//

import Foundation
import EssentialFeeds
 class InMemoryFeedStore: FeedStore, FeedImageDataStore {
    private var feedImageDataCache: [URL: Data] = [:]
    private(set) var feedCache: CacheFeed?
    
    func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        feedCache = nil
        completion(.success(()))
    }
    
    private init(feedCache: CacheFeed? = nil) {
        self.feedCache = feedCache
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertCompletion) {
        feedCache = CacheFeed(feed: feed, timestamp: timestamp)
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping FeedStore.RetrieveCompletion) {
        completion(.success(feedCache))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        feedImageDataCache[url] = data
        completion(.success(()))
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(feedImageDataCache[url]))
    }
    
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CacheFeed(feed: [], timestamp: Date.distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CacheFeed(feed: [], timestamp: Date()))
    }
}
