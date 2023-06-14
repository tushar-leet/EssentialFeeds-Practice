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
        let (_,loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadFeeds(){
        let (sut,loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    // MARK: HELPERS
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (controller:FeedViewController,spy:LoaderSpy){
        let loader = LoaderSpy()
        let sut = FeedViewController(loader:loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut,loader)
    }
    
    class LoaderSpy:FeedLoader{
        private(set) var loadCallCount = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}
