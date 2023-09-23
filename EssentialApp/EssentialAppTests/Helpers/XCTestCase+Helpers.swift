//
//  XCTestCase+Helpers.swift
//  EssentialAppTests
//
//  Created by TUSHAR SHARMA on 19/09/23.
//

import XCTest
import EssentialFeeds
import EssentialFeedIOS
import EssentialApp

extension FeedUIIntegrationTests{
    func assertThat(_ sut: ListViewController, isRendering feed: [FeedImage],withLoader imageLoader:LoaderSpy? = nil, file: StaticString = #file, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image,withLoader: imageLoader, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: ListViewController, hasViewConfiguredFor image: FeedImage,withLoader imageLoader:LoaderSpy? = nil, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        imageLoader?.completeImageLoading(with: imageData0, at: index)
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image  view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)
    }
}
