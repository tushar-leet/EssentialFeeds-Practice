//
//  FeedImageDataStore.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 08/08/23.
//

import Foundation

public protocol FeedImageDataStore {
     typealias InsertionResult = Swift.Result<Void, Error>
     typealias Result = Swift.Result<Data?, Error>

     func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
     func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
 }
