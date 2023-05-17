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
    
    private func makeSut(currentDate:@escaping ()->Date = Date.init,file:StaticString = #filePath, line:UInt = #line) -> (LocalFeedLoader,FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return (sut,store)
    }
}
