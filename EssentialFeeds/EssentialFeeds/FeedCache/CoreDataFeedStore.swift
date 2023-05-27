//
//  CoreDataFeedStore.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 27/05/23.
//

import Foundation
import CoreData


public final class CoreDataFeedStore:FeedStore{
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL,bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
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
