//
//  CoreDataFeedStoreSpecs.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 27/05/23.
//

import XCTest
import EssentialFeeds

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
   
     func test_retrieve_deliversEmptyOnEmptyCache() {
         let sut = makeSut()
         assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
     }

     func test_retrieve_hasNoSideEffectsOnEmptyCache() {
         let sut = makeSut()
         assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
     }

     func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
         let sut = makeSut()
         assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
     }

     func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
         let sut = makeSut()
         assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
     }

     func test_insert_deliversNoErrorOnEmptyCache() {
         let sut = makeSut()
         assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
     }

     func test_insert_deliversNoErrorOnNonEmptyCache() {
         let sut = makeSut()
         assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
     }

     func test_insert_overridesPreviouslyInsertedCacheValues() {
         let sut = makeSut()
         assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
     }

     func test_delete_deliversNoErrorOnEmptyCache() {
         let sut = makeSut()
         assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
     }

     func test_delete_hasNoSideEffectsOnEmptyCache() {
         let sut = makeSut()
         assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
     }

     func test_delete_deliversNoErrorOnNonEmptyCache() {
         let sut = makeSut()
         assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
     }

     func test_delete_emptiesPreviouslyInsertedCache() {
         let sut = makeSut()
         assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
     }

     func test_storeSideEffects_runSerially() {
         let sut = makeSut()
         assertThatSideEffectsRunSerially(on: sut)
     }

    func makeSut(file:StaticString = #filePath, line:UInt = #line) -> FeedStore{
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL,bundle: storeBundle)
        trackForMemoryLeaks(sut,file: file,line:line)
        return sut
    }
 }
