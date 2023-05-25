//
//  CodableFeedStoreTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 25/05/23.
//

import Foundation
import XCTest
import EssentialFeeds

class CodableFeedStore{
    
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
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timeStamp))
    }
    
    func insert(_ feeds:[LocalFeedImage],timestamp:Date,completion:@escaping FeedStore.InsertCompletion){
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feeds.map(CodableFeedImage.init), timeStamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
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
    
    // MARK: HELPERS
    private func makeSUT(file:StaticString = #filePath, line:UInt = #line) -> CodableFeedStore{
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private func insert(_ cache:(feed:[LocalFeedImage],timestamp:Date), to sut:CodableFeedStore){
        let exp = expectation(description: "wait for cache insertion")
        sut.insert(cache.feed,timestamp: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError,"Expected Feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func expect(_ sut:CodableFeedStore,toRetrieveTwice expectedResult:RetrieveCachedFeedResult,file:StaticString = #filePath, line:UInt = #line){
        expect(sut, toCompleteWith: expectedResult,file: file,line: line)
        expect(sut, toCompleteWith: expectedResult,file: file,line: line)
    }
    
    private func expect(_ sut:CodableFeedStore,toCompleteWith expectedResult:RetrieveCachedFeedResult,file:StaticString = #filePath, line:UInt = #line){
        let exp = expectation(description: "Wait for load completion")

        sut.retrieve { retriveResult in
            switch (retriveResult,expectedResult){
            case  (.empty,.empty):
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
