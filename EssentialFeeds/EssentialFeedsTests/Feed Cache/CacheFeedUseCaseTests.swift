//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 09/05/23.
//

import XCTest
import EssentialFeeds

class FeedStore{
    var deleteCachedFeedCallCount = 0
    
    func deleteCachedFeed(){
        deleteCachedFeedCallCount += 1
    }
}

class LocalFeedLoader{
    var store:FeedStore
    init(store:FeedStore){
        self.store = store
    }
    
    func save(_ items:[FeedItems]){
        store.deleteCachedFeed()
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    func test(){
        let (_,store) = makeSut()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

    func test_save_requestCacheDeletion(){
        let (sut,store) = makeSut()
        let items = [uniqueItems(),uniqueItems()]
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }

    // MARK: - Helpers

    private func makeSut() -> (LocalFeedLoader,FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store:store)
        return (sut,store)
    }

    private func uniqueItems() -> FeedItems{
        FeedItems(id: UUID(), description: "Any", location: "Any", imageURL: anyURL())
    }

    private func anyURL() -> URL{
        URL(string: "http://any-url.com")!
    }
}
