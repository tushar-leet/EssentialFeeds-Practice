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
        store.retrieve{ [unowned self] result in
            switch result{
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed,timestamp) where self.validate(timestamp):
                completion(.success(feed.toModels()))
            case .found,.empty:
                completion(.success([]))
            }
        }
    }
    
    private func validate(_ timestamp:Date) -> Bool{
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value:7, to: timestamp) else{
            return false
        }
        
        return currentDate() < maxCacheAge
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

private extension Array where Element == LocalFeedImage{
    func toModels() -> [FeedImage]{
        map{FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
