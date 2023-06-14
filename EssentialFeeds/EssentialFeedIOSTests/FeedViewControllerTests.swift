//
//  EssentialFeedIOSTests.swift
//  EssentialFeedIOSTests
//
//  Created by TUSHAR SHARMA on 11/06/23.
//

import XCTest
import UIKit
import EssentialFeeds

class FeedViewController:UITableViewController{
    
    private var loader: FeedLoader?
    
    convenience init(loader:FeedLoader){
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        load()
    }
    
    @objc func load(){
        loader?.load{ [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
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
    
    func test_userInitiatedFeedReload_loadFeeds(){
        let (sut,loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator(){
        let (sut,_) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorOnLoadingCompletion(){
        let (sut,loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_userInitiatedFeedReload_showsLoadingIndicator(){
        let (sut,_) = makeSUT()
       
        sut.simulateUserInitatedFeedReload()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    }
    
    func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoadingCompletion(){
        let (sut,loader) = makeSUT()
       
        sut.simulateUserInitatedFeedReload()
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
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
       
        typealias loadCompletion = (FeedLoader.Result) -> Void
        var completionArray = [loadCompletion]()
        
        var loadCallCount:Int{
            completionArray.count
        }
        
        func load(completion: @escaping loadCompletion) {
            completionArray.append(completion)
        }
        
        func completeFeedLoading(at index:Int = 0){
            completionArray[index](.success([]))
        }
    }
}

private extension UIRefreshControl{
    func simulatePullToRefresh(){
        allTargets.forEach { target in
           actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension FeedViewController{
    func simulateUserInitatedFeedReload(){
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator:Bool{
        return refreshControl?.isRefreshing == true
    }
}