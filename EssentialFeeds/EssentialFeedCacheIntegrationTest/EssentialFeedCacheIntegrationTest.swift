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
        let expectation = expectation(description: "Wait for load completion")
        
        sut.load{ result in
            switch result{
            case let .success(feedImge):
                XCTAssertEqual(feedImge, [],"expected empty feed image")
            case let .failure(error):
                XCTFail("expected successfull fead result got \(error) instead")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnSeprateInstance(){
        let sutToPerformSave = makeSUT()
        let sutToPerformFetch = makeSUT()
        let feed = uniqueImageFeed().models
        
        let saveExp = expectation(description: "Wait for save")
        
        sutToPerformSave.save(feed) { saveError in
            XCTAssertNil(saveError,"Expected to save feed successfully")
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1.0)
        
        let loadExp = expectation(description: "Wait for load result")
        sutToPerformFetch.load { loadResult in
            switch loadResult{
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, feed)
            case let .failure(error):
                XCTFail("expected to save obj successfully but got : \(error) insead")
            }
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 1.0)
    }
    
    // MARK: - HELPERS
    
    func makeSUT(file:StaticString = #filePath, line:UInt = #line) -> LocalFeedLoader{
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL,bundle:bundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
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
