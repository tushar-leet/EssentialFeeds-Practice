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

    public func save(_ items:[FeedItems],completion:@escaping (Error?) -> Void){
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else{return}
            if let cacheDeletionError = error{
                completion(cacheDeletionError)
            }else{
                self.insert(items: items, with: completion)
            }
        }
    }
    
    private func insert(items:[FeedItems], with completion:@escaping (Error?) -> Void){
        store.insert(items, timestamp: currentDate()) { [weak self] error in
            guard  self != nil else{return}
                completion(error)
        }
    }
}
