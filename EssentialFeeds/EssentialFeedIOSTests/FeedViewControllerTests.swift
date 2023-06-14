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
        load()
    }
    
    @objc func load(){
        refreshControl?.beginRefreshing()
        loader?.load{ [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requiredFeedFromLoader(){
        let (sut,loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0,"Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1,"Expected a loading request once view is loaded")

        sut.simulateUserInitatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2,"Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3,"Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed(){
        let (sut,loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator,"Expected loading indicator once view is loaded")
  
        loader.completeFeedLoading(0)
        XCTAssertFalse(sut.isShowingLoadingIndicator,"Expected no loading indicator once loading is completed")
   
        sut.simulateUserInitatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator,"Expected loading indicator once user initiates a reload")
 
        loader.completeFeedLoading(1)
        XCTAssertFalse(sut.isShowingLoadingIndicator,"Expected no loading indicator once user initiated loading is completed")
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
        
        func completeFeedLoading(_ index:Int = 0){
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
