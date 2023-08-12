//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by TUSHAR SHARMA on 11/08/23.
//

import EssentialFeeds

 class FeedLoaderStub: FeedLoader {
     private let result: FeedLoader.Result

     init(result: FeedLoader.Result) {
         self.result = result
     }

     func load(completion: @escaping (FeedLoader.Result) -> Void) {
         completion(result)
     }
 }
