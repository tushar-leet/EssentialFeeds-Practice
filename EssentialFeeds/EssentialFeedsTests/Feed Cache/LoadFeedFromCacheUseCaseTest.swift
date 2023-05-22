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
        let retrievelError = anyNSError()
        expect(sut, toCompleteWith: .failure(retrievelError)) {
            store.completeRetrievel(with:retrievelError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache(){
        let (sut,store) = makeSut()
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievelWithEmptyCache()
        }
    }

    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.addind(days: -7).adding(seconds: 1)
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        expect(sut, toCompleteWith: .success(uniqueFeed.models)) {
            store.completeRetrievel(with:uniqueFeed.localModel,timestamp:lessThanSevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.addind(days: -7)
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievel(with:uniqueFeed.localModel,timestamp:sevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.addind(days: -7).adding(seconds: -1)
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievel(with:uniqueFeed.localModel,timestamp:sevenDaysOldTimestamp)
        }
    }
    
    func test_load_hasNoSideEffectOnRetrievelError(){
        let (sut,store) = makeSut()
        
        sut.load { _ in
            
        }
        store.completeRetrievel(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnEmptyCache(){
        let (sut,store) = makeSut()
        
        sut.load { _ in
            
        }
        store.completeRetrievelWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnLessThanSevenDaysOldCache(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.addind(days: -7).adding(seconds: 1)
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        sut.load { _ in
            
        }
        store.completeRetrievel(with: uniqueFeed.localModel, timestamp: lessThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnSevenDaysOldCache(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.addind(days: -7)
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        sut.load { _ in
            
        }
        store.completeRetrievel(with: uniqueFeed.localModel, timestamp: lessThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnMoreThanSevenDaysOldCache(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.addind(days: -7).adding(seconds: -1)
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        sut.load { _ in
            
        }
        store.completeRetrievel(with: uniqueFeed.localModel, timestamp: lessThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut:LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResult = [LocalFeedLoader.LoadResult]()
        
        sut?.load{receivedResult.append($0)}
        sut = nil
        store.completeRetrievelWithEmptyCache()
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    private func makeSut(currentDate:@escaping ()->Date = Date.init,file:StaticString = #filePath, line:UInt = #line) -> (LocalFeedLoader,FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return (sut,store)
    }
    
    private func expect(_ sut:LocalFeedLoader,toCompleteWith expectedResult:LocalFeedLoader.LoadResult, when action:()->Void,file:StaticString = #filePath, line:UInt = #line){
        let exp = expectation(description: "Wait for load completion")

        sut.load{ receivedResult in
            switch (receivedResult,expectedResult){
            case let (.success(receivedImages),.success(expectedImages)):
                XCTAssertEqual(receivedImages,expectedImages,file: file,line: line)
            case let (.failure(receivedError as NSError),.failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError,file:file,line:line)
            default:
                XCTFail("expected result : \(expectedResult) received \(receivedResult) instead")
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
}
