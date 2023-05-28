//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 27/05/23.
//

import XCTest
import EssentialFeeds

extension FeedStoreSpecs where Self: XCTestCase {

     func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         expect(sut, toRetrieve: .empty, file: file, line: line)
     }

     func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         expect(sut, toRetrieveTwice: .empty, file: file, line: line)
     }

     func
    assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         let feed = uniqueImageFeed().localModel
         let timestamp = Date()

         insert((feed, timestamp), to: sut)

         expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp), file: file, line: line)
     }

     func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         let feed = uniqueImageFeed().localModel
         let timestamp = Date()

         insert((feed, timestamp), to: sut)

         expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp), file: file, line: line)
     }

     func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         let insertionError = insert((uniqueImageFeed().localModel, Date()), to: sut)

         XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
     }

     func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         insert((uniqueImageFeed().localModel, Date()), to: sut)

         let insertionError = insert((uniqueImageFeed().localModel, Date()), to: sut)

         XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
     }

     func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         insert((uniqueImageFeed().localModel, Date()), to: sut)

         let latestFeed = uniqueImageFeed().localModel
         let latestTimestamp = Date()
         insert((latestFeed, latestTimestamp), to: sut)

         expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp), file: file, line: line)
     }

     func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         let deletionError = deleteCache(from: sut)

         XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
     }

     func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         deleteCache(from: sut)

         expect(sut, toRetrieve: .empty, file: file, line: line)
     }

     func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         insert((uniqueImageFeed().localModel, Date()), to: sut)

         let deletionError = deleteCache(from: sut)

         XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
     }

     func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         insert((uniqueImageFeed().localModel, Date()), to: sut)

         deleteCache(from: sut)

         expect(sut, toRetrieve: .empty, file: file, line: line)
     }

     func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         var completedOperationsInOrder = [XCTestExpectation]()

         let op1 = expectation(description: "Operation 1")
         sut.insert(uniqueImageFeed().localModel, timestamp: Date()) { _ in
             completedOperationsInOrder.append(op1)
             op1.fulfill()
         }

         let op2 = expectation(description: "Operation 2")
         sut.deleteCachedFeed { _ in
             completedOperationsInOrder.append(op2)
             op2.fulfill()
         }

         let op3 = expectation(description: "Operation 3")
         sut.insert(uniqueImageFeed().localModel, timestamp: Date()) { _ in
             completedOperationsInOrder.append(op3)
             op3.fulfill()
         }

         waitForExpectations(timeout: 5.0)

         XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
     }

 }

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
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
    }
    
    func expect(_ sut:FeedStore,toRetrieve expectedResult:RetrieveCachedFeedResult,file:StaticString = #filePath, line:UInt = #line){
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
