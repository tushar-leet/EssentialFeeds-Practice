//
//  FeedLoader.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import Foundation

public enum LoadFeedResults{
    case success([FeedItems])
    case failure(Error)
}

protocol FeedLoader{
    func load(completion: @escaping (LoadFeedResults) -> Void)
}
