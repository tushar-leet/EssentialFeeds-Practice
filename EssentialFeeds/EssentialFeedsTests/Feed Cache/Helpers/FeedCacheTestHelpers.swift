//
//  FeedCacheTestHelpers.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 22/05/23.
//

import Foundation
import EssentialFeeds



func uniqueImageFeed() -> (models:[FeedImage],localModel:[LocalFeedImage]){
    let items = [uniqueFeed(),uniqueFeed()]
    let localFeedItems = items.map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    return (items,localFeedItems)
}

func uniqueFeed() -> FeedImage{
    FeedImage(id: UUID(), description: "Any", location: "Any", url: anyURL())
}

extension Date{
    func minusFeedCacheMaxAge() -> Date{
        addind(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays:Int{
        return 7
    }
    
    func addind(days:Int) -> Date{
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds:TimeInterval) -> Date{
        self + seconds
    }
}
