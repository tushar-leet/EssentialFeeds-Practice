//
//  FeedStoreSpec.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 27/05/23.
//

import Foundation

protocol FeedStoreSpecs{
     func test_retrieve_deliversEmptyOnEmptyCache()
     func test_retrieve_hasNoSideEffectsOnEmptyCache()
     func test_retrieve_deliversFoundValuesOnNonEmptyCache()
     func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
     
    
     func test_insert_overridesPreviouslyInsertedCacheValues()
     func test_insert_deliversNoErrorOnEmptyCache()
     func test_insert_deliversNoErrorOnNonEmptyCache()
    
     func test_delete_hasNoSideEffectsOnEmptyCache()
     func test_delete_emptiesPreviouslyInsertedCache()
     func test_delete_deliversNoErrorOnEmptyCache()
     func test_delete_deliversNoErrorOnNonEmptyCache()
    
     func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpec:FeedStoreSpecs{
    func test_retrieve_deliversFailureOnRetrievelError()
    func test_retrieve_hasNoSideEffectOnRetrievelError()
}

protocol FailableInsertFeedStoreSpec:FeedStoreSpecs{
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectOnInsertionError()
}

protocol FailableDeleteFeedStoreSpec:FeedStoreSpecs{
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStore = FailableRetrieveFeedStoreSpec & FailableInsertFeedStoreSpec & FailableDeleteFeedStoreSpec
