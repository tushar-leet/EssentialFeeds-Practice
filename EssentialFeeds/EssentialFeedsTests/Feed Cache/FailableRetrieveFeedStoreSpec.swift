//
//  FailableRetrieveFeedStoreSpec.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 27/05/23.
//


import XCTest
import EssentialFeeds

 extension FailableRetrieveFeedStoreSpec where Self: XCTestCase {
     func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
     }

     func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
     }
 }
