//
//  FeedLoader.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import Foundation

public enum LoadFeedResults<Error:Swift.Error>{
    case success([FeedItems])
    case failure(Error)
}

extension LoadFeedResults:Equatable where Error:Equatable{}

protocol FeedLoader{
    associatedtype Error:Swift.Error
    func load(completion: @escaping (LoadFeedResults<Error>) -> Void)
}
