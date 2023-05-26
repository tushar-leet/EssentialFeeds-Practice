//
//  FeedStore.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 13/05/23.
//

import Foundation

public enum RetrieveCachedFeedResult{
    case empty
    case found(feed:[LocalFeedImage],timestamp:Date)
    case failure(Error)
}

public protocol FeedStore{
    typealias DeletionCompletion = (Error?) -> ()
    typealias InsertCompletion = (Error?) -> ()
    typealias RetrieveCompletion = (RetrieveCachedFeedResult) -> ()
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion:@escaping DeletionCompletion)
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feeds:[LocalFeedImage],timestamp:Date,completion:@escaping InsertCompletion)
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion:@escaping RetrieveCompletion)
}

