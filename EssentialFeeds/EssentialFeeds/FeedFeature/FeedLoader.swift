//
//  FeedLoader.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import Foundation

public typealias LoadFeedResults = Result<[FeedImage],Error>

public protocol FeedLoader{
    func load(completion: @escaping (LoadFeedResults) -> Void)
}
