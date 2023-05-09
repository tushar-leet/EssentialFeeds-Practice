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
    var insertions = [(items:[FeedItems],timestamp:Date)]()

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

    func insert(_ items:[FeedItems],timestamp:Date){
        insertcacheFeedCallCount += 1
        insertions.append((items,timestamp))
    }
}

class LocalFeedLoader{
    var store:FeedStore
    let currentDate:() -> Date

    init(store:FeedStore,currentDate:@escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items:[FeedItems]){
        store.deleteCachedFeed { [unowned self] error in
            if error == nil{
                self.store.insert(items, timestamp: self.currentDate())
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

    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfullDeletion(){
        let timestamp = Date()
        let (sut,store) = makeSut(currentDate: {timestamp})
        let items = [uniqueItems(),uniqueItems()]
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertions.count,1)
        XCTAssertEqual(store.insertions.first?.items,items)
        XCTAssertEqual(store.insertions.first?.timestamp,timestamp)
    }
    // MARK: - Helpers

    private func makeSut(currentDate:@escaping ()->Date = Date.init,file:StaticString = #filePath, line:UInt = #line) -> (LocalFeedLoader,FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
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
