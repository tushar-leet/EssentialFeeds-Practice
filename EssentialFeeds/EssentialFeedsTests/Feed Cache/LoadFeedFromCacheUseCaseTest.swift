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
    
    private func anyNSError() -> NSError{
        NSError(domain: "Any error", code: 0)
    }
    
    private func uniqueImageFeed() -> (models:[FeedImage],localModel:[LocalFeedImage]){
        let items = [uniqueFeed(),uniqueFeed()]
        let localFeedItems = items.map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
        return (items,localFeedItems)
    }
    
    private func uniqueFeed() -> FeedImage{
        FeedImage(id: UUID(), description: "Any", location: "Any", url: anyURL())
    }

    private func anyURL() -> URL{
        URL(string: "http://any-url.com")!
    }
}

private extension Date{
    func addind(days:Int) -> Date{
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds:TimeInterval) -> Date{
        self + seconds
    }
}
