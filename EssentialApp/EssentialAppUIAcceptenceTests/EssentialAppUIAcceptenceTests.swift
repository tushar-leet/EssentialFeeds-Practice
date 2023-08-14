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
}

