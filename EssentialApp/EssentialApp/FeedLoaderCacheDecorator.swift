//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by TUSHAR SHARMA on 11/08/23.
//

import EssentialFeeds
import Combine

 public final class FeedLoaderCacheDecorator: FeedLoader {
     private let decoratee: FeedLoader
     private let cache: FeedCache

     public init(decoratee: FeedLoader, cache: FeedCache) {
         self.decoratee = decoratee
         self.cache = cache
     }

     public func load(completion: @escaping (FeedLoader.Result) -> Void) {
         decoratee.load { [weak self] result in
             completion(result.map { feed in
                 self?.cache.saveIgnoringResult(feed)
                 return feed
             })
         }
     }
 }
