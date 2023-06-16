//
//  EssentialFeedIOSTests.swift
//  EssentialFeedIOSTests
//
//  Created by TUSHAR SHARMA on 11/06/23.
//

import XCTest
import UIKit
import EssentialFeeds
import EssentialFeedIOS

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
        XCTAssertFalse(sut.isShowingLoadingIndicator,"Expected no loading indicator once load completes successfully")
   
        sut.simulateUserInitatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator,"Expected loading indicator once user initiates a reload")
 
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator,"Expected no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeeds(){
        let image0 = makeImage(description:"a description",location:"a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 0)
        
        loader.completeFeedLoading(with: [image0],0)
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 1)
        
        let view = sut.feedImageView(at: 0) as? FeedImageCell
        XCTAssertNotNil(view)
        assertThat(sut, hasViewConfiguredFor: image0, at: 0)
        
        sut.simulateUserInitatedFeedReload()
        loader.completeFeedLoading(with: [image0,image1,image2,image3],1)
        assertThat(sut, isRendering: [image0,image1,image2,image3])
    }
    
    func test_loadFeedCompletion_doesNotAltersCurrentRendringStateOnError(){
        let (sut,loader) = makeSUT()
        let image0 = makeImage()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0],0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    // MARK: HELPERS
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (controller:FeedViewController,spy:LoaderSpy){
        let loader = LoaderSpy()
        let sut = FeedViewController(loader:loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut,loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }

    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image  view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)
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
        
        func completeFeedLoading(with feed:[FeedImage] = [],_ index:Int = 0){
            completionArray[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index:Int = 0){
            let error = NSError(domain: "a error", code: 0)
            completionArray[index](.failure(error))
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
    
    func numberOfRenderedFeedImageViews() -> Int{
        tableView.numberOfRows(inSection:feedImageSection)
    }
    
    func feedImageView(at row:Int) -> UITableViewCell?{
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedImageSection:Int{
        0
    }
}

private extension FeedImageCell{
    var isShowingLocation:Bool{
        !locationContainer.isHidden
    }
    
    var locationText:String?{
        locationLabel.text
    }
    
    var descriptionText:String?{
        descriptionLabel.text
    }
}
