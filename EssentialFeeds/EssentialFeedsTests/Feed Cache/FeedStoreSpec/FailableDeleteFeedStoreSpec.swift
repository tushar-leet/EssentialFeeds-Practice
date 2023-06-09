//
//  FailableDeleteFeedStoreSpec.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 27/05/23.
//

import XCTest
import EssentialFeeds

 extension FailableDeleteFeedStoreSpec where Self: XCTestCase {
     func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         let deletionError = deleteCache(from: sut)

         XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
     }

     func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         deleteCache(from: sut)

         expect(sut, toRetrieve: .success(.empty), file: file, line: line)
     }
 }
