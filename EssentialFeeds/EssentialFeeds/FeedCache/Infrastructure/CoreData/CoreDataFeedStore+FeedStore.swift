//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 08/08/23.
//

import CoreData

 extension CoreDataFeedStore: FeedStore {

     public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
         perform { context in
             completion(Result(catching: {
                 try ManagedCache.find(in: context).map(context.delete).map(context.save)
             }))
         }
     }
     
     public func insert(_ feeds: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
         perform { context in
             completion(Result(catching: {
                 let managedCache = try ManagedCache.newUniqueInstance(in: context)
                 managedCache.timestamp = timestamp
                 managedCache.feed = ManagedFeedImage.images(from: feeds, in: context)
                 try context.save()
             }))
         }
     }
     
     public func retrieve(completion: @escaping RetrieveCompletion) {
         perform { context in
             completion(Result{
                 try ManagedCache.find(in: context).map  {
                      CacheFeed(
                         feed: $0.localFeed,
                         timestamp: $0.timestamp)
                 }
             })
         }
     }
 }
