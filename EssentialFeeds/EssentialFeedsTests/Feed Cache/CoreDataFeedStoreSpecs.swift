//
//  CoreDataFeedStoreSpecs.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 27/05/23.
//

import XCTest
import EssentialFeeds

public final class CoreDataFeedStore:FeedStore{
    
    public init(){}
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feeds: [EssentialFeeds.LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        completion(.empty)
    }
}

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
   
     func test_retrieve_deliversEmptyOnEmptyCache() {
         let sut = makeSut()
         assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
     }

     func test_retrieve_hasNoSideEffectsOnEmptyCache() {
         let sut = makeSut()
         assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
     }

     func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
         let sut = makeSut()
     }

     func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {

     }

     func test_insert_deliversNoErrorOnEmptyCache() {

     }

     func test_insert_deliversNoErrorOnNonEmptyCache() {

     }

     func test_insert_overridesPreviouslyInsertedCacheValues() {

     }

     func test_delete_deliversNoErrorOnEmptyCache() {

     }

     func test_delete_hasNoSideEffectsOnEmptyCache() {

     }

     func test_delete_deliversNoErrorOnNonEmptyCache() {

     }

     func test_delete_emptiesPreviouslyInsertedCache() {

     }

     func test_storeSideEffects_runSerially() {

     }

    func makeSut(file:StaticString = #filePath, line:UInt = #line) -> FeedStore{
        let sut = CoreDataFeedStore()
        trackForMemoryLeaks(sut,file: file,line:line)
        return sut
    }
 }
