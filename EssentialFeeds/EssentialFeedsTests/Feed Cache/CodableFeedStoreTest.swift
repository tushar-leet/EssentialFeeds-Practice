//
//  CodableFeedStoreTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 25/05/23.
//

import Foundation
import XCTest
import EssentialFeeds

final class CodableFeedStoreTest: XCTestCase,FailableFeedStore {
   
    override  func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override  func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache(){
        let sut = makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache(){
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache(){
        let sut = makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache(){
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFailureOnRetrievelError(){
        let storeUrl = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeUrl)
        try! "invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
        assertThatRetrieveDeliversFailureOnRetrievalError(on:sut)
    }
    
    func test_retrieve_hasNoSideEffectOnRetrievelError(){
        let storeUrl = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeUrl)
        try! "invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError(){
        let storeURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: storeURL)
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_insert_hasNoSideEffectOnInsertionError(){
        let storeURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: storeURL)
        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache(){
        let sut = makeSUT()
    
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache(){
        let sut = makeSUT()
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues(){
        let sut = makeSUT()
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache(){
        let sut = makeSUT()
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache(){
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache(){
        let sut = makeSUT()
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }
    
    func test_storeSideEffects_runSerially(){
        let sut = makeSUT()
        assertThatSideEffectsRunSerially(on: sut)
    }
    
    // MARK: HELPERS
    
    private func makeSUT(storeURL:URL? = nil, file:StaticString = #filePath, line:UInt = #line) -> FeedStore{
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private func setupEmptyStoreState(){
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects(){
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func cachesDirectory() -> URL{
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func noDeletePermissionURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
    
    private func testSpecificStoreURL() -> URL{
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
}
