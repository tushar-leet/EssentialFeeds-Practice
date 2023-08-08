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
    
    public init(store:FeedStore,currentDate:@escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader{
    
    public typealias SaveResult = Result<Void,Error>
    
    public func save(_ items:[FeedImage],completion:@escaping (SaveResult) -> Void){
        store.deleteCachedFeed { [weak self] deletionResult in
            guard  self != nil else{return}
            switch deletionResult{
            case .success:
                self?.insert(feeds: items, with: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func insert(feeds:[FeedImage], with completion:@escaping (SaveResult) -> Void){
        store.insert(feeds.toLocal(), timestamp: currentDate()) { [weak self] insertionCompletion in
            guard  self != nil else{return}
                completion(insertionCompletion)
        }
    }
}
    
extension LocalFeedLoader:FeedLoader{
    
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion:@escaping (LoadResult) -> Void){
        store.retrieve{ [weak self] result in
            guard let self = self else {return}
            switch result{
            case let .failure(error):
                completion(.failure(error))
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader{
    public typealias ValidationResult = Result<Void, Error>
    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve{ [weak self] result in
            guard let self = self else{
                return
            }
            switch result{
            case .failure:
                self.store.deleteCachedFeed { _ in completion(.success(())) }
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp,against:self.currentDate()):
                self.store.deleteCachedFeed { _ in completion(.success(())) }
            case .success:
                completion(.success(()))
            }
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
