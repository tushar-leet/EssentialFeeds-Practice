//
//  LocalFeedLoader.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 13/05/23.
//

import Foundation


public final class LocalFeedLoader{
    var store:FeedStore
    let currentDate:() -> Date
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResults

    public init(store:FeedStore,currentDate:@escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }

    public func save(_ items:[FeedImage],completion:@escaping (SaveResult) -> Void){
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else{return}
            if let cacheDeletionError = error{
                completion(cacheDeletionError)
            }else{
                self.insert(feeds: items, with: completion)
            }
        }
    }
    
    public func load(completion:@escaping (LoadResult) -> Void){
        store.retrieve{ error in
            if let error = error{
                completion(.failure(error))
            }else{
                completion(.success([]))
            }
        }
    }
    
    private func insert(feeds:[FeedImage], with completion:@escaping (SaveResult) -> Void){
        store.insert(feeds.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard  self != nil else{return}
                completion(error)
        }
    }
}

private extension Array where Element == FeedImage{
    func toLocal() -> [LocalFeedImage]{
        map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
