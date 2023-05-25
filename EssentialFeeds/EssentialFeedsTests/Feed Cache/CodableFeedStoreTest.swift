//
//  CodableFeedStoreTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 25/05/23.
//

import Foundation
import XCTest
import EssentialFeeds

class CodableFeedStore{
    func retrieve(completion:@escaping FeedStore.RetrieveCompletion){
        completion(.empty)
    }
}

final class CodableFeedStoreTest: XCTestCase {
    func test_retrieve_deliversEmptyOnEmptyCache(){
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for cache retrievel")
        sut.retrieve { result in
            switch result{
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
