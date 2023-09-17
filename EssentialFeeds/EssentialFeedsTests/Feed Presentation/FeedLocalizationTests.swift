//
//  FeedLocalizationTests.swift
//  EssentialFeedIOSTests
//
//  Created by TUSHAR SHARMA on 31/07/23.
//

import XCTest
@testable import EssentialFeeds

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
