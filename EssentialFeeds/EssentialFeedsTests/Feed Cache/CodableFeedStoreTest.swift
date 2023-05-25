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
        let exp = expectation(description: "wait for cache retrievel")
        sut.retrieve { result in
            switch result{
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache(){
        let sut = makeSUT()
        let exp = expectation(description: "wait for cache retrievel")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult,secondResult){
                case (.empty,.empty):
                    break
                default:
                    XCTFail("Expected empty result twice , got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues(){
        let sut = makeSUT()
        let feed = uniqueImageFeed().localModel
        let timestamp = Date()
        let exp = expectation(description: "wait for cache retrievel")
        sut.insert(feed,timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError,"Expected Feed to be inserted successfully")
            sut.retrieve { retrieveResult in
                switch retrieveResult{
                case let .found(retrieveFeed,retrieveTimeStamp):
                    XCTAssertEqual(retrieveFeed, feed)
                    XCTAssertEqual(retrieveTimeStamp, timestamp)
                default:
                    XCTFail("Expected found result with \(feed) and \(timestamp) but got \(retrieveResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: HELPERS
    private func makeSUT(file:StaticString = #filePath, line:UInt = #line) -> CodableFeedStore{
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL{
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
