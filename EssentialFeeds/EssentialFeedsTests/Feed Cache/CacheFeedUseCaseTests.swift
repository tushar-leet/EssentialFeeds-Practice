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
   
    enum ReceivedMessages:Equatable{
        case deleteCachedFeed
        case insert([FeedItems],Date)
    }
    
    private var deletionCompletion = [DeletionCompletion]()
    private(set) var receivedMessages = [ReceivedMessages]()

    func deleteCachedFeed(completion:@escaping DeletionCompletion){
        deletionCompletion.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }

    func completeDeletion(with error:Error?, at index:Int = 0){
        deletionCompletion[index](error)
    }

    func completeDeletionSuccessfully(at index:Int = 0){
        deletionCompletion[index](nil)
    }

    func insert(_ items:[FeedItems],timestamp:Date){
        receivedMessages.append(.insert(items, timestamp))
    }
}

class LocalFeedLoader{
    var store:FeedStore
    let currentDate:() -> Date

    init(store:FeedStore,currentDate:@escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items:[FeedItems],completion:@escaping (Error?) -> Void){
        store.deleteCachedFeed { [unowned self] error in
            completion(error)
            if error == nil{
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    func test(){
        let (_,store) = makeSut()
        XCTAssertEqual(store.receivedMessages,[])
    }

    func test_save_requestCacheDeletion(){
        let (sut,store) = makeSut()
        let items = [uniqueItems(),uniqueItems()]
        sut.save(items){ _ in}
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (sut,store) = makeSut()
        let items = [uniqueItems(),uniqueItems()]
        sut.save(items) { _ in}
        let deletionError =  anyNSError()
        store.completeDeletion(with:deletionError)
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfullDeletion(){
        let timestamp = Date()
        let (sut,store) = makeSut(currentDate: {timestamp})
        let items = [uniqueItems(),uniqueItems()]
        sut.save(items){ _ in}
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed,.insert(items, timestamp)])
    }
    
    func test_save_failsOnDeletionError(){
        let (sut,store) = makeSut()
        let items = [uniqueItems(),uniqueItems()]
        var receivedError:Error?
        let expectation = expectation(description: "fails on save")
        sut.save(items){ error in
            receivedError = error
            expectation.fulfill()
        }
        let deletionError =  anyNSError()
        store.completeDeletion(with:deletionError)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, deletionError)
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
