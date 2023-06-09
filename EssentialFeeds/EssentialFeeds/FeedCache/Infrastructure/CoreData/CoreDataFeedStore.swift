//
//  CoreDataFeedStore.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 27/05/23.
//


import CoreData

public final class CoreDataFeedStore:FeedStore{
    
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
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
                    completion(.success(.found(
                        feed: cache.localFeed,
                        timestamp: cache.timestamp)))
                } else {
                    completion(.success(.empty))
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

