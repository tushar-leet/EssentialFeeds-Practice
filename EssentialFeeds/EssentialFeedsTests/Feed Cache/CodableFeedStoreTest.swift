//
//  CodableFeedStoreTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 25/05/23.
//

import Foundation
import XCTest
import EssentialFeeds

class CodableFeedStore:FeedStore{
    
    private struct Cache:Codable{
        let feed:[CodableFeedImage]
        let timeStamp:Date
        
        var localFeed:[LocalFeedImage]{
            feed.map{$0.local}
        }
    }
    
    private struct CodableFeedImage:Codable{
        private let id:UUID
        private let description:String?
        private let location:String?
        private let url:URL
        
        init(_ image:LocalFeedImage)  {
            id = image.id
            description = image.description
            location = image.description
            url = image.url
        }
        
        var local:LocalFeedImage{
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL:URL
    
    init(storeURL:URL){
        self.storeURL = storeURL
    }
    
    func retrieve(completion:@escaping FeedStore.RetrieveCompletion){
        guard let data = try? Data(contentsOf: storeURL) else{
            completion(.empty)
            return
        }
        do{
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timeStamp))
        }catch{
            completion(.failure(error))
        }
    }
    
    func insert(_ feeds:[LocalFeedImage],timestamp:Date,completion:@escaping FeedStore.InsertCompletion){
        do{
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(Cache(feed: feeds.map(CodableFeedImage.init), timeStamp: timestamp))
            try encoded.write(to: storeURL)
            completion(nil)
        }catch{
            completion(error)
        }
    }
    
    func deleteCachedFeed(completion:@escaping FeedStore.DeletionCompletion){
        guard FileManager.default.fileExists(atPath: storeURL.path) else{
            return completion(nil)
        }
        
        do{
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch{
            completion(error)
        }
    }
}

final class CodableFeedStoreTest: XCTestCase {
    
    override  func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    override  func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
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
    
    func test_insert_overridesPreviouslyInsertedCachedValues(){
        let sut = makeSUT()
        let firstInsertionError = insert((uniqueImageFeed().localModel,Date()), to: sut)
        XCTAssertNil(firstInsertionError,"")
        
        let latestFeed = uniqueImageFeed().localModel
        let lstestTimeStamp = Date()
        
        let secondInsertionError = insert((latestFeed,lstestTimeStamp), to: sut)
        expect(sut, toCompleteWith: .found(feed: latestFeed, timestamp: lstestTimeStamp))
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache(){
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError,"Expected empty cache deletion to nil")
        
        expect(sut, toCompleteWith: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache(){
        let sut = makeSUT()
        insert((uniqueImageFeed().localModel,Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError,"Expected empty cache deletion to nil")
        
        expect(sut, toCompleteWith: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError(){
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        insert((uniqueImageFeed().localModel,Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError,"Expected empty cache deletion to nil")
        
        expect(sut, toCompleteWith: .empty)
    }
    
    // MARK: HELPERS
    private func makeSUT(storeURL:URL? = nil, file:StaticString = #filePath, line:UInt = #line) -> FeedStore{
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
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
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
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
    
    private func testSpecificStoreURL() -> URL{
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
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
