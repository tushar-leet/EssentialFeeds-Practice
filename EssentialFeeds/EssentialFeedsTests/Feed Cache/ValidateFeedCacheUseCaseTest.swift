//
//  ValidateFeedCacheUseCaseTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 22/05/23.
//

import XCTest
import EssentialFeeds

final class ValidateFeedCacheUseCaseTest: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_,store) = makeSut()
        XCTAssertEqual(store.receivedMessages,[])
    }
    
    func test_load_deleteCacheOnRetrievelError(){
        let (sut,store) = makeSut()
        
        sut.validateCache()
        store.completeRetrievel(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache(){
        let (sut,store) = makeSut()
        
        sut.validateCache()
        store.completeRetrievelWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotdeletesNonExpiredCache(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        sut.validateCache()
        store.completeRetrievel(with: uniqueFeed.localModel, timestamp: nonExpiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deleteCacheOnExpiration(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        sut.validateCache()
        store.completeRetrievel(with: uniqueFeed.localModel, timestamp: expirationTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
    }
    
    func test_validateCache_deletesExpiredCache(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        sut.validateCache()
        store.completeRetrievel(with: uniqueFeed.localModel, timestamp: expiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheIfSUTHasBeenDeallocated(){
        let feedStore = FeedStoreSpy()
        var localFeedLoader:LocalFeedLoader? = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        
        localFeedLoader?.validateCache()
        localFeedLoader = nil
        feedStore.completeRetrievel(with: anyNSError())
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
        
    }
    
    private func makeSut(currentDate:@escaping ()->Date = Date.init,file:StaticString = #filePath, line:UInt = #line) -> (LocalFeedLoader,FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return (sut,store)
    }
}

