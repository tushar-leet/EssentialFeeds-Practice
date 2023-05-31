//
//  FeedLoader.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import Foundation

public enum LoadFeedResults{
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader{
    func load(completion: @escaping (LoadFeedResults) -> Void)
}
