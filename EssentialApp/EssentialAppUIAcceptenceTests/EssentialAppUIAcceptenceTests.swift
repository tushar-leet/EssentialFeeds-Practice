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
        XCTAssertEqual(app.cells.count, 22)
        XCTAssertEqual(app.firstMatch.images.count, 1)
    }
}

