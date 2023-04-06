//
//  FeedLoader.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import Foundation

enum LoadFeedResults{
    case success([FeedItems])
    case error(Error)
}
protocol FeedLoader{
    func load(completion: @escaping (LoadFeedResults) -> Void)
}
