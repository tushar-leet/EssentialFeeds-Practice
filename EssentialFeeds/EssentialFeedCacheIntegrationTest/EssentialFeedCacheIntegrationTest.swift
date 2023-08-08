//
//  EssentialFeedCacheIntegrationTest.swift
//  EssentialFeedCacheIntegrationTest
//
//  Created by TUSHAR SHARMA on 30/05/23.
//

import XCTest
import EssentialFeeds

final class EssentialFeedCacheIntegrationTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        setupEmptyStoreState()
    }
    
    func test_load_deliversNoItemOnEmptyCache(){
        let sut = makeSUT()
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnSeprateInstance(){
        let sutToPerformSave = makeSUT()
        let sutToPerformFetch = makeSUT()
        let feed = uniqueImageFeed().models
        
        save(feed, with: sutToPerformSave)
    
        expect(sutToPerformFetch, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models
        
        save(firstFeed, with: sutToPerformFirstSave)
        save(latestFeed, with: sutToPerformLastSave)
        
        expect(sutToPerformLoad, toLoad: latestFeed)
    }
    
    // MARK: - HELPERS
    
    func makeSUT(file:StaticString = #filePath, line:UInt = #line) -> LocalFeedLoader{
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut:LocalFeedLoader,toLoad expectedFeed:[FeedImage],file:StaticString = #filePath, line:UInt = #line){
        let loadExp = expectation(description: "Wait for load result")
        sut.load { loadResult in
            switch loadResult{
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, expectedFeed,file: file,line: line)
            case let .failure(error):
                XCTFail("expected to save obj successfully but got : \(error) insead")
            }
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 1.0)
    }
    
    private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected to save feed successfully", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func cachesDirectory() -> URL{
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificStoreURL() -> URL{
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func deleteStoreArtifacts(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func setupEmptyStoreState(){
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects(){
        deleteStoreArtifacts()
    }
}
