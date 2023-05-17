//
//  LoadFeedFromCacheUseCaseTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 16/05/23.
//

import XCTest
import EssentialFeeds

final class LoadFeedFromCacheUseCaseTest: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation(){
        let (_,store) = makeSut()
        XCTAssertEqual(store.receivedMessages,[])
    }
    
    func test_load_requestCacheInterval(){
        let (sut,store) = makeSut()
        sut.load { _ in}
        XCTAssertEqual(store.receivedMessages,[.retrieve])
    }
    
    func test_load_failsOnRetrievelError(){
        let (sut,store) = makeSut()
        var receivedError:Error?
        let retrievelError = anyNSError()
        let exp = expectation(description: "Wait for load completion")
        
        sut.load{ result in
            switch result{
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("expected error received response instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrievel(with:retrievelError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError? ,retrievelError)
    }
    
    func test_load_deliversNoImagesOnEmptyCache(){
        let (sut,store) = makeSut()
        var retrievelImages = [FeedImage]()
        let exp = expectation(description: "Wait for load completion")

        sut.load{ result in
            switch result{
            case let .success(images):
                retrievelImages = images
            default:
                XCTFail("expected success received \(result) instead")
            }
            exp.fulfill()
        }

        store.completeRetrievelWithEmptyCache()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(retrievelImages,[])
    }

    private func makeSut(currentDate:@escaping ()->Date = Date.init,file:StaticString = #filePath, line:UInt = #line) -> (LocalFeedLoader,FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return (sut,store)
    }
    
    private func anyNSError() -> NSError{
        NSError(domain: "Any error", code: 0)
    }
}
