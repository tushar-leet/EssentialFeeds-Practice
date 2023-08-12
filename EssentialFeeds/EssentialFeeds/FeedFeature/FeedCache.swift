//
//  FeedCache.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 11/08/23.
//

import Foundation

 public protocol FeedCache {
     typealias Result = Swift.Result<Void, Error>

     func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
 }
