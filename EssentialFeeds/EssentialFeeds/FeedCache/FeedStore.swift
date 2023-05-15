//
//  FeedStore.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 13/05/23.
//

import Foundation

public protocol FeedStore{
    typealias DeletionCompletion = (Error?) -> ()
    typealias InsertCompletion = (Error?) -> ()
    func deleteCachedFeed(completion:@escaping DeletionCompletion)
    func insert(_ items:[LocalFeedItems],timestamp:Date,completion:@escaping InsertCompletion)
}

