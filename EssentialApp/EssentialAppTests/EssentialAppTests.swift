//
//  EssentialAppTests.swift
//  EssentialAppTests
//
//  Created by TUSHAR SHARMA on 09/08/23.
//

import XCTest
import EssentialFeeds

class FeedLoaderWithFallbackComposit:FeedLoader{
    private let primary: FeedLoader
    init(primary:FeedLoader,fallback:FeedLoader){
        self.primary = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

final class RemoteWithLocalFallbackFeedLoaderTest: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess(){
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposit(primary:primaryLoader,fallback:fallbackLoader)
        let expectation = XCTestExpectation(description: "wait for load completion")
        sut.load{result in
            switch result{
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed,primaryFeed)
            case .failure:
                XCTFail("expected successfull load feed result, got \(result) instead")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    private class LoaderStub:FeedLoader{
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
    }
}
