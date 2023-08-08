//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 08/08/23.
//


import Foundation

 extension CoreDataFeedStore: FeedImageDataStore {

     public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {

     }

     public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
         completion(.success(.none))
     }

 }
