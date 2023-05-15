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

public struct LocalFeedItems:Equatable{
    public let id:UUID
    public let description:String?
    public let location:String?
    public let imageURL:URL
    
    public init( id:UUID,
                 description:String?,
                 location:String?,
                 imageURL:URL){
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
