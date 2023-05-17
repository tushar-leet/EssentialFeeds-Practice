//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 09/05/23.
//

import XCTest
import EssentialFeeds

final class CacheFeedUseCaseTests: XCTestCase {

    func test(){
        let (_,store) = makeSut()
        XCTAssertEqual(store.receivedMessages,[])
    }

    func test_save_requestCacheDeletion(){
        let (sut,store) = makeSut()
        let feeds = uniqueImageFeed()
        sut.save(feeds.models){ _ in}
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let (sut,store) = makeSut()
        let feeds =  uniqueImageFeed()
        sut.save(feeds.models) { _ in}
        let deletionError =  anyNSError()
        store.completeDeletion(with:deletionError)
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfullDeletion(){
        let timestamp = Date()
        let (sut,store) = makeSut(currentDate: {timestamp})
        let feeds = uniqueImageFeed()
        sut.save(feeds.models){ _ in}
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed,.insert(feeds.localModel, timestamp)])
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
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models, completion: { error in
            receivedResults.append(error)
        })
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorIfSUTIsDeallocated(){
        let store = FeedStoreSpy()
        var sut:LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models, completion: { error in
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
        let items = uniqueImageFeed()
        var receivedError:Error?
        let expectation = expectation(description: "fails on save")
        sut.save(items.models){ error in
            receivedError = error
            expectation.fulfill()
        }
        action()
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError,file: file,line: line)
    }

    private func uniqueFeed() -> FeedImage{
        FeedImage(id: UUID(), description: "Any", location: "Any", url: anyURL())
    }

    private func anyNSError() -> NSError{
        NSError(domain: "Any error", code: 0)
    }
    
    private func uniqueImageFeed() -> (models:[FeedImage],localModel:[LocalFeedImage]){
        let items = [uniqueFeed(),uniqueFeed()]
        let localFeedItems = items.map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
        return (items,localFeedItems)
    }

    private func anyURL() -> URL{
        URL(string: "http://any-url.com")!
    }
}
