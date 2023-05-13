//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 09/05/23.
//

import XCTest
import EssentialFeeds

protocol FeedStore{
    typealias DeletionCompletion = (Error?) -> ()
    typealias InsertCompletion = (Error?) -> ()
    func deleteCachedFeed(completion:@escaping DeletionCompletion)
    func insert(_ items:[FeedItems],timestamp:Date,completion:@escaping InsertCompletion)
}

class FeedStoreSpy:FeedStore{
    typealias DeletionCompletion = (Error?) -> ()
    typealias InsertCompletion = (Error?) -> ()
   
    enum ReceivedMessages:Equatable{
        case deleteCachedFeed
        case insert([FeedItems],Date)
    }
    
    private var deletionCompletion = [DeletionCompletion]()
    private var insertCompletion = [InsertCompletion]()
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

    func insert(_ items:[FeedItems],timestamp:Date,completion:@escaping InsertCompletion){
        receivedMessages.append(.insert(items, timestamp))
        insertCompletion.append(completion)
    }
    
    func completeInsertion(with error:Error?, at index:Int = 0){
        insertCompletion[index](error)
    }
    
    func completeInsertionSuccessfully(at index:Int = 0){
        insertCompletion[index](nil)
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
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else{return}
            if error == nil{
                self.store.insert(items, timestamp: self.currentDate()) { [weak self] error in
                    guard  self != nil else{return}
                    if error != nil{
                        completion(error)
                    }
                }
            }else{
                completion(error)
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
        let deletionError =  anyNSError()
        expect(sut: sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError(){
        let (sut,store) = makeSut()
        let insertionError =  anyNSError()
        expect(sut: sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfullCacheInsertion(){
        let (sut,store) = makeSut()
        expect(sut: sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorIfSUTIsDeallocated(){
        let store = FeedStoreSpy()
        var sut:LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [Error?]()
        sut?.save([uniqueItems()], completion: { error in
            receivedResults.append(error)
        })
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorIfSUTIsDeallocated(){
        let store = FeedStoreSpy()
        var sut:LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [Error?]()
        sut?.save([uniqueItems()], completion: { error in
            receivedResults.append(error)
        })
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    // MARK: - Helpers

    private func makeSut(currentDate:@escaping ()->Date = Date.init,file:StaticString = #filePath, line:UInt = #line) -> (LocalFeedLoader,FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return (sut,store)
    }
    
    private func expect(sut:LocalFeedLoader, toCompleteWithError expectedError:NSError?, when action:()->Void,file:StaticString = #filePath, line:UInt = #line){
        let items = [uniqueItems(),uniqueItems()]
        var receivedError:Error?
        let expectation = expectation(description: "fails on save")
        sut.save(items){ error in
            receivedError = error
            expectation.fulfill()
        }
        action()
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError,file: file,line: line)
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
