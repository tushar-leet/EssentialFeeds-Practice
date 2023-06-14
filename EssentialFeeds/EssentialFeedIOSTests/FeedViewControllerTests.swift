//
//  EssentialFeedIOSTests.swift
//  EssentialFeedIOSTests
//
//  Created by TUSHAR SHARMA on 11/06/23.
//

import XCTest
import UIKit
import EssentialFeeds

class FeedViewController:UIViewController{
    
    private var loader: FeedLoader?
    
    convenience init(loader:FeedLoader){
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load{_ in}
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed(){
        let loader = LoaderSpy()
        let _ = FeedViewController(loader:loader)
        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadFeeds(){
        let loader = LoaderSpy()
        let sut = FeedViewController(loader:loader)
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    // MARK: HELPERS
    
    class LoaderSpy:FeedLoader{
        private(set) var loadCallCount = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}
