//
//  EssentialAppUIAcceptenceTests.swift
//  EssentialAppUIAcceptenceTests
//
//  Created by TUSHAR SHARMA on 12/08/23.
//

import XCTest

final class EssentialAppUIAcceptenceTests: XCTestCase {
    func test_onLaunch_displayRemoteFeedWhenCustomerHasConnectivity(){
        let app = XCUIApplication()
        app.launch()
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)
        let feedImages = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(feedImages.exists)
    }
    
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count, 22)
        
        let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstCachedImage.exists)
        
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "offline"]
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 0)
    }
}

