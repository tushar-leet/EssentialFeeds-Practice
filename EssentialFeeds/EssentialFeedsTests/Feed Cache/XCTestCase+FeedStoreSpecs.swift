//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 27/05/23.
//

import XCTest
import EssentialFeeds

extension FeedStoreSpecs where Self:XCTestCase{
    
    @discardableResult
    func deleteCache(from sut:FeedStore) -> Error?{
        let exp = expectation(description: "wait for cache deletion")
        var deletionError:Error?
        sut.deleteCachedFeed { retrievedDeletionError in
            deletionError = retrievedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    @discardableResult
    func insert(_ cache:(feed:[LocalFeedImage],timestamp:Date), to sut:FeedStore) -> Error?{
        let exp = expectation(description: "wait for cache insertion")
        var insertionError:Error?
        sut.insert(cache.feed,timestamp: cache.timestamp) { retrieveInsertionError in
            insertionError = retrieveInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    func expect(_ sut:FeedStore,toRetrieveTwice expectedResult:RetrieveCachedFeedResult,file:StaticString = #filePath, line:UInt = #line){
        expect(sut, toCompleteWith: expectedResult,file: file,line: line)
        expect(sut, toCompleteWith: expectedResult,file: file,line: line)
    }
    
    func expect(_ sut:FeedStore,toCompleteWith expectedResult:RetrieveCachedFeedResult,file:StaticString = #filePath, line:UInt = #line){
        let exp = expectation(description: "Wait for load completion")
        
        sut.retrieve { retriveResult in
            switch (retriveResult,expectedResult){
            case  (.empty,.empty),
                (.failure,.failure):
                break
            case let (.found(expected),.found(retrieved)):
                XCTAssertEqual(retrieved.feed, expected.feed)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp)
            default:
                XCTFail("Expected  to retrieve \(expectedResult) result,  but got \(retriveResult) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
