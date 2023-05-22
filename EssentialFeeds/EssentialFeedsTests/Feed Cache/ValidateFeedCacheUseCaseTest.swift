//
//  ValidateFeedCacheUseCaseTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 22/05/23.
//

import XCTest
import EssentialFeeds

final class ValidateFeedCacheUseCaseTest: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_,store) = makeSut()
        XCTAssertEqual(store.receivedMessages,[])
    }
    
    func test_load_deleteCacheOnRetrievelError(){
        let (sut,store) = makeSut()
        
        sut.validateCache()
        store.completeRetrievel(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
    }
    
    func test_load_doesNotDeleteCacheOnEmptyCache(){
        let (sut,store) = makeSut()
        
        sut.validateCache()
        store.completeRetrievelWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotdeletesCacheOnLessThanSevenDaysOldCache(){
        let uniqueFeed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.addind(days: -7).adding(seconds: 1)
        let (sut,store) = makeSut(currentDate:{fixedCurrentDate})
        sut.validateCache()
        store.completeRetrievel(with: uniqueFeed.localModel, timestamp: lessThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
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
