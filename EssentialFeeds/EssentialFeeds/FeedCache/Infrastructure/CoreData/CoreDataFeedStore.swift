//
//  CoreDataFeedStore.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 27/05/23.
//


import CoreData

public final class CoreDataFeedStore:FeedStore{
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do{
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            }catch{
                completion(error)
            }
        }
    }
    
    public func insert(_ feeds: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feeds, in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context)  {
                    completion(.found(
                        feed: cache.localFeed,
                        timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}

