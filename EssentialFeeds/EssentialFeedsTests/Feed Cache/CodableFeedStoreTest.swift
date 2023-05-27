//
//  CodableFeedStoreTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 25/05/23.
//

import Foundation
import XCTest
import EssentialFeeds

protocol FeedStoreSpecs{
     func test_retrieve_deliversEmptyOnEmptyCache()
     func test_retrieve_hasNoSideEffectOnEmptyCache()
     func test_retrieve_deliversFoundValueOnNonEmptyCache()
     func test_retrieve_hasNoSideEffectOnNonEmptyCache()
     
    
     func test_insert_overridesPreviouslyInsertedCachedValues()
     func test_delete_hasNoSideEffectsOnEmptyCache()
     func test_delete_emptiesPreviouslyInsertedCache()
     func test_storeSideeffects_runsSerially()
}

protocol FailableRetrieveFeedStoreSpec{
    func test_retrieve_deliversFailureOnRetrievelError()
    func test_retrieve_hasNoSideEffectOnRetrievelError()
}

protocol FailableInsertFeedStoreSpec{
    func test_insert_deliversErrorOnInsertionError()
}

protocol FailableDeleteFeedStoreSpec{
    func test_delete_deliversErrorOnDeletionError()
}

final class CodableFeedStoreTest: XCTestCase {
    
    override  func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override  func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache(){
        let sut = makeSUT()
        expect(sut, toCompleteWith: .empty)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache(){
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValueOnNonEmptyCache(){
        let sut = makeSUT()
        let feed = uniqueImageFeed().localModel
        let timestamp = Date()
        
        insert((feed,timestamp), to: sut)
        expect(sut, toCompleteWith: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectOnNonEmptyCache(){
        let sut = makeSUT()
        let feed = uniqueImageFeed().localModel
        let timestamp = Date()
        
        insert((feed,timestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievelError(){
        let storeUrl = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeUrl)
        try! "invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectOnRetrievelError(){
        let storeUrl = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeUrl)
        try! "invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversErrorOnInsertionError(){
        let storeURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: storeURL)
        let feed = uniqueImageFeed().localModel
        let timestamp = Date()
        
        let insertionError = insert((feed,timestamp), to: sut)
        
        XCTAssertNotNil(insertionError,"Expected sut to complete with insertion error")
    }
    
    func test_insert_hasNoSideEffectOnInsertionError(){
        let storeURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: storeURL)
        let feed = uniqueImageFeed().localModel
        let timestamp = Date()
        
        insert((feed,timestamp), to: sut)
        
        expect(sut, toCompleteWith: .empty)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache(){
        let sut = makeSUT()
    
        let insertionError =  insert((uniqueImageFeed().localModel,Date()), to: sut)
        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache(){
        let sut = makeSUT()
        insert((uniqueImageFeed().localModel,Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().localModel
        let lstestTimeStamp = Date()
        
        let insertionError = insert((latestFeed,lstestTimeStamp), to: sut)
        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }
    
    func test_insert_overridesPreviouslyInsertedCachedValues(){
        let sut = makeSUT()
        insert((uniqueImageFeed().localModel,Date()), to: sut)
        
        
        let latestFeed = uniqueImageFeed().localModel
        let lstestTimeStamp = Date()
        
        insert((latestFeed,lstestTimeStamp), to: sut)
        expect(sut, toCompleteWith: .found(feed: latestFeed, timestamp: lstestTimeStamp))
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache(){
        let sut = makeSUT()
        
        deleteCache(from: sut)
       
        expect(sut, toCompleteWith: .empty)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache(){
        let sut = makeSUT()
        insert((uniqueImageFeed().localModel,Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError,"Expected empty cache deletion to nil")
    }
    
    func test_delete_emptiesPreviouslyInsertedCache(){
        let sut = makeSUT()
        insert((uniqueImageFeed().localModel,Date()), to: sut)
        
        deleteCache(from: sut)
       
        expect(sut, toCompleteWith: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
//        let noDeletePermissionURL = cachesDirectory()
//        let sut = makeSUT(storeURL: noDeletePermissionURL)
//
//        let deletionError = deleteCache(from: sut)
//
//        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
//        expect(sut, toCompleteWith: .empty)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
//        let noDeletePermissionURL = cachesDirectory()
//        let sut = makeSUT(storeURL: noDeletePermissionURL)
//
//        deleteCache(from: sut)
//
//        expect(sut, toCompleteWith: .empty)
    }
    
    func test_storeSideeffects_runsSerially(){
        let sut = makeSUT()
        var completedExpectationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "operation 1")
        sut.insert(uniqueImageFeed().localModel, timestamp: Date()) { _ in
            completedExpectationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "operation 2")
        sut.deleteCachedFeed { _ in
            completedExpectationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "operation 3")
        sut.insert(uniqueImageFeed().localModel, timestamp: Date()) { _ in
            completedExpectationsInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(completedExpectationsInOrder, [op1,op2,op3])
    }
    
    // MARK: HELPERS
    private func makeSUT(storeURL:URL? = nil, file:StaticString = #filePath, line:UInt = #line) -> FeedStore{
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    @discardableResult
    private func deleteCache(from sut:FeedStore) -> Error?{
        let exp = expectation(description: "wait for cache deletion")
        var deletionError:Error?
        sut.deleteCachedFeed { retrievedDeletionError in
            deletionError = retrievedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    private func cachesDirectory() -> URL{
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificStoreURL() -> URL{
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    @discardableResult
    private func insert(_ cache:(feed:[LocalFeedImage],timestamp:Date), to sut:FeedStore) -> Error?{
        let exp = expectation(description: "wait for cache insertion")
        var insertionError:Error?
        sut.insert(cache.feed,timestamp: cache.timestamp) { retrieveInsertionError in
            insertionError = retrieveInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    private func setupEmptyStoreState(){
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects(){
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func expect(_ sut:FeedStore,toRetrieveTwice expectedResult:RetrieveCachedFeedResult,file:StaticString = #filePath, line:UInt = #line){
        expect(sut, toCompleteWith: expectedResult,file: file,line: line)
        expect(sut, toCompleteWith: expectedResult,file: file,line: line)
    }
    
    private func expect(_ sut:FeedStore,toCompleteWith expectedResult:RetrieveCachedFeedResult,file:StaticString = #filePath, line:UInt = #line){
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
