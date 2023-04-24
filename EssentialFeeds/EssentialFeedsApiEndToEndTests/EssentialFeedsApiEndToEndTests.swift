//
//  EssentialFeedsApiEndToEndTests.swift
//  EssentialFeedsApiEndToEndTests
//
//  Created by TUSHAR SHARMA on 24/04/23.
//

import XCTest
import EssentialFeeds

class EssentialFeedsApiEndToEndTests: XCTestCase {
    
    func test_endToEndServerGetFeedResults_matchesFixedTestAccountData(){
        switch getFeedResults() {
        case let .success(item):
            XCTAssertEqual(item.count, 8,"total feed item counts is 8")
        case let .failure(error):
            XCTFail("expected feed items , but received \(error) instead")
        default:
            XCTFail("expected successfull feed result, got no result instead")
        }
    }
    
    private func getFeedResults() -> LoadFeedResults?{
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: url, client: client)
        
        let expectation = expectation(description: "wait for load completion")
        var receivedResult:LoadFeedResults?
        
        loader.load { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
        return receivedResult
    }
}
