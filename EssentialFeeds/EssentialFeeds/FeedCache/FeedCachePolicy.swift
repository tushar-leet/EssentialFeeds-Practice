//
//  FeedCachePolicy.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 22/05/23.
//

import Foundation

internal final class FeedCachePolicy{
    private init() {}
    private  static let calendar = Calendar(identifier: .gregorian)
    
    internal static func validate(_ timestamp:Date,against date:Date) -> Bool{
        guard let maxCacheAge = calendar.date(byAdding: .day, value:7, to: timestamp) else{
            return false
        }
        return date < maxCacheAge
    }
}
