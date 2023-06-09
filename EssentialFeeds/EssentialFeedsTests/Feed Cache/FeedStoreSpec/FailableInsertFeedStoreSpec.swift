//
//  FailableInsertFeedStoreSpec.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 27/05/23.
//

import XCTest
import EssentialFeeds

 extension FailableInsertFeedStoreSpec where Self: XCTestCase {
     func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         let insertionError = insert((uniqueImageFeed().localModel, Date()), to: sut)

         XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
     }

     func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         insert((uniqueImageFeed().localModel, Date()), to: sut)

         expect(sut, toRetrieve: .success(.empty), file: file, line: line)
     }
 }
