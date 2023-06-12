//
//  EssentialFeedIOSTests.swift
//  EssentialFeedIOSTests
//
//  Created by TUSHAR SHARMA on 11/06/23.
//

import XCTest

class FeedViewController{
    init(loader:FeedViewControllerTests.LoaderSpy){
        
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed(){
        let loader = LoaderSpy()
        let _ = FeedViewController(loader:loader)
        XCTAssertEqual(loader.loadCallCount, 0)
    }

    // MARK: HELPERS
    
    class LoaderSpy{
        private(set) var loadCallCount = 0
    }
}
