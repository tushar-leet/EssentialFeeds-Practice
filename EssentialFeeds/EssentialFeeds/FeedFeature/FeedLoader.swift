//
//  FeedLoader.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import Foundation

public protocol FeedLoader{
    typealias Result = Swift.Result<[FeedImage],Error>
    func load(completion: @escaping (Result) -> Void)
}
