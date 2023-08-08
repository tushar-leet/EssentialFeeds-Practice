//
//  FeedImageDataStore.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 08/08/23.
//

import Foundation

public protocol FeedImageDataStore {
     typealias Result = Swift.Result<Data?, Error>

     func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
 }
