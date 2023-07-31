//
//  FeedViewControllerTest+Localization.swift
//  EssentialFeedIOSTests
//
//  Created by TUSHAR SHARMA on 31/07/23.
//

import Foundation
import XCTest
import EssentialFeedIOS

extension FeedUIIntegrationTests {
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
