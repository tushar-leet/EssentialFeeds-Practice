//
//  FeedImageDataCache.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 12/08/23.
//

import Foundation
public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
