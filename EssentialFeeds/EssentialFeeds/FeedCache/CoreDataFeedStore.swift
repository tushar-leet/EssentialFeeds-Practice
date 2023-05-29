//
//  CoreDataFeedStore.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 27/05/23.
//

import Foundation
import CoreData

@objc(ManagedCache)
public class ManagedCache: NSManagedObject {
     @NSManaged var timestamp: Date
     @NSManaged var feed: NSSet
     
    var localFeed:[LocalFeedImage]{
        feed.compactMap{($0 as? ManagedFeedImage)?.local}
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context:NSManagedObjectContext) throws -> ManagedCache{
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
 }

@objc(ManagedFeedImage)
 public  class ManagedFeedImage: NSManagedObject {
     @NSManaged var id: UUID
     @NSManaged var imageDescription: String?
     @NSManaged var location: String?
     @NSManaged var url: URL
     @NSManaged var cache: ManagedCache
     
     static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSSet {
         return NSSet(array: localFeed.map { local in
             let managed = ManagedFeedImage(context: context)
             managed.id = local.id
             managed.imageDescription = local.description
             managed.location = local.location
             managed.url = local.url
             return managed
         })
     }
     
     var local:LocalFeedImage{
         LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
     }
 }

public final class CoreDataFeedStore:FeedStore{
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(nil)
    }
    
    public func insert(_ feeds: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        let context = self.context
        context.perform {
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
        let context = self.context
        context.perform {
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
}

private extension NSPersistentContainer {
     enum LoadingError: Swift.Error {
         case modelNotFound
         case failedToLoadPersistentStores(Swift.Error)
     }

     static func load(modelName name: String,url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
         guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
             throw LoadingError.modelNotFound
         }

         let description = NSPersistentStoreDescription(url: url)
         let container = NSPersistentContainer(name: name, managedObjectModel: model)
         container.persistentStoreDescriptions = [description]
         
         var loadError: Swift.Error?
         container.loadPersistentStores { loadError = $1 }
         try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }

         return container
     }
 }

 private extension NSManagedObjectModel {
     static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
         let url = bundle.url(forResource: name, withExtension: "momd")
         let model = url.flatMap { NSManagedObjectModel(contentsOf: $0) }
         return model
     }
 }
