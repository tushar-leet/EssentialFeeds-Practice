//
//  SharedLocalizationTests.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 16/09/23.
//

import XCTest
import EssentialFeeds

final class SharedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any,DummyView>.self)
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
    
    private class DummyView:ResourceView{
        func display(_ viewModel: Any) {
        }
    }
}
