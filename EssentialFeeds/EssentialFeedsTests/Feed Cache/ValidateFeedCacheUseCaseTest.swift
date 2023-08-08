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
        
        sut.validateCache{ _ in }
        store.completeRetrievel(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache(){
        let (sut,store) = makeSut()
        
        sut.validateCache{ _ in }
        store.completeRetrievelWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotdeletesNonExpiredCache(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        sut.validateCache{ _ in }
        store.completeRetrievel(with: uniqueFeed.localModel, timestamp: nonExpiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deleteCacheOnExpiration(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        sut.validateCache{ _ in }
        store.completeRetrievel(with: uniqueFeed.localModel, timestamp: expirationTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
    }
    
    func test_validateCache_deletesExpiredCache(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        sut.validateCache{ _ in }
        store.completeRetrievel(with: uniqueFeed.localModel, timestamp: expiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheIfSUTHasBeenDeallocated(){
        let feedStore = FeedStoreSpy()
        var localFeedLoader:LocalFeedLoader? = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        
        localFeedLoader?.validateCache{ _ in }
        localFeedLoader = nil
        feedStore.completeRetrievel(with: anyNSError())
        
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
        
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (sut, store) = makeSut()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrievel(with: anyNSError())
            store.completeDeletion(with: deletionError)
        })
    }

    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
        let (sut, store) = makeSut()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievel(with: anyNSError())
            store.completeDeletionSuccessfully()
        })
    }
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (sut, store) = makeSut()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievelWithEmptyCache()
        })
    }
    
    func test_validateCache_succeedsOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSut(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievel(with: feed.localModel, timestamp: nonExpiredTimestamp)
        })
    }
    
    private func makeSut(currentDate:@escaping ()->Date = Date.init,file:StaticString = #filePath, line:UInt = #line) -> (LocalFeedLoader,FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return (sut,store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.ValidationResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.validateCache { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}

