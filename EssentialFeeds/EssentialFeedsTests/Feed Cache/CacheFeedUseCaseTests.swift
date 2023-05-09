//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 09/05/23.
//

import XCTest
import EssentialFeeds

class FeedStore{
    typealias DeletionCompletion = (Error?) -> ()
    var deleteCacheFeedCallCount = 0
    var insertcacheFeedCallCount = 0
    
    private var deletionCompletion = [DeletionCompletion]()

    func deleteCachedFeed(completion:@escaping DeletionCompletion){
        deletionCompletion.append(completion)
        deleteCacheFeedCallCount += 1
    }

    func completeDeletion(with error:Error?, at index:Int = 0){
        deletionCompletion[index](error)
    }

    func completeDeletionSuccessfully(at index:Int = 0){
        deletionCompletion[index](nil)
    }

    func insert(_ items:[FeedItems]){
        insertcacheFeedCallCount += 1
    }
}

class LocalFeedLoader{
    var store:FeedStore
    init(store:FeedStore){
        self.store = store
    }
    
    func save(_ items:[FeedItems]){
        store.deleteCachedFeed { [unowned self] error in
            if error == nil{
                self.store.insert(items)
            }
        }
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    func test(){
        let (_,store) = makeSut()
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }

    func test_save_requestCacheDeletion(){
        let (sut,store) = makeSut()
        let items = [uniqueItems(),uniqueItems()]
        sut.save(items)
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (sut,store) = makeSut()
        let items = [uniqueItems(),uniqueItems()]
        sut.save(items)
        let deletionError =  anyNSError()
        store.completeDeletion(with:deletionError)
        XCTAssertEqual(store.insertcacheFeedCallCount,0)
    }

    func test_save_requestNewCacheInsertionOnSuccessfullDeletion(){
        let (sut,store) = makeSut()
        let items = [uniqueItems(),uniqueItems()]
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertcacheFeedCallCount,1)
    }

    // MARK: - Helpers

    private func makeSut(file:StaticString = #filePath, line:UInt = #line) -> (LocalFeedLoader,FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store:store)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return (sut,store)
    }

    private func uniqueItems() -> FeedItems{
        FeedItems(id: UUID(), description: "Any", location: "Any", imageURL: anyURL())
    }

    private func anyNSError() -> NSError{
        NSError(domain: "Any error", code: 0)
    }

    private func anyURL() -> URL{
        URL(string: "http://any-url.com")!
    }
}
