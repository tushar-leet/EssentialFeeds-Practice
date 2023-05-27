//
//  CoreDataFeedStore.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 27/05/23.
//

import Foundation
import CoreData


public final class CoreDataFeedStore:FeedStore{
    
    public init(){}
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feeds: [EssentialFeeds.LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        completion(.empty)
    }
}

private class ManagedCache: NSManagedObject {
     @NSManaged var timestamp: Date
     @NSManaged var feed: NSOrderedSet
 }

 private class ManagedFeedImage: NSManagedObject {
     @NSManaged var id: UUID
     @NSManaged var imageDescription: String?
     @NSManaged var location: String?
     @NSManaged var url: URL
     @NSManaged var cache: ManagedCache
 }
