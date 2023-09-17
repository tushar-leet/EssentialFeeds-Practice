//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 17/09/23.
//

import XCTest
import EssentialFeeds

final class ImageCommentsLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
