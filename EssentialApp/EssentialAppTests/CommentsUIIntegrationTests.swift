//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by TUSHAR SHARMA on 19/09/23.
//

import XCTest
import UIKit
import EssentialFeeds
import EssentialFeedIOS
import EssentialApp
import Combine

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {

    func test_commentView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title,commentTitle)
    }

    func test_loadCommentsActions_requestCommentsFromLoader(){
        let (sut,loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0,"Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1,"Expected a loading request once view is loaded")

        sut.simulateUserInitatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2,"Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3,"Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments(){
        let (sut,loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator,"Expected loading indicator once view is loaded")
  
        loader.completeCommentsLoading(0)
        XCTAssertFalse(sut.isShowingLoadingIndicator,"Expected no loading indicator once load completes successfully")
   
        sut.simulateUserInitatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator,"Expected loading indicator once user initiates a reload")
 
        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator,"Expected no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments(){
        let comment0 = makeComment(message:"a message",username:"a location")
        let comment1 = makeComment(message: "another message", username: "another username")
     
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [comment0],0)
        assertThat(sut, isRendering: [comment0])
        
//        let view = sut.feedImageView(at: 0) as? FeedImageCell
//        XCTAssertNotNil(view)
//        assertThat(sut, hasViewConfiguredFor: comment0, at: 0)
        
        sut.simulateUserInitatedReload()
        loader.completeCommentsLoading(with: [comment0,comment1],1)
        assertThat(sut, isRendering: [comment0,comment1])
    }
    
    func test_loadCommentCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment],0)
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitatedReload()
        loader.completeCommentsLoading(with: [], 1)
        assertThat(sut, isRendering: [])
    }

    func test_loadCommentCompletion_doesNotAltersCurrentRendringStateOnError(){
        let (sut,loader) = makeSUT()
        let comment = makeComment()

        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment],0)
        assertThat(sut, isRendering: [comment])

        sut.simulateUserInitatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment])
    }
    
    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        sut.simulateUserInitatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    
//    override func test_loadFeedCompletion_doesNotAltersCurrentRendringStateOnError(){
//        let (sut,loader) = makeSUT()
//        let image0 = makeImage()
//
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [image0],0)
//        assertThat(sut, isRendering: [image0], withLoader: loader)
//
//        sut.simulateUserInitatedFeedReload()
//        loader.completeFeedLoadingWithError(at: 1)
//        assertThat(sut, isRendering: [image0], withLoader: loader)
//    }

    
//    override func test_feedImageView_loadImageWhenVisible(){
//        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
//        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
//        let (sut, loader) = makeSUT()
//
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [image0, image1])
//
//        XCTAssertEqual(loader.loadedImageURLs, [],"Expected no image URL request unit view becomes visible")
//
//        sut.simulateFeedImageViewVisible(at: 0)
//        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")
//    }
//
//    override func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
//        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
//        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
//        let (sut, loader) = makeSUT()
//
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [image0, image1])
//        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
//
//        sut.simulateFeedImageViewNotVisible(at: 0)
//        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")
//
//        sut.simulateFeedImageViewNotVisible(at: 1)
//        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
//    }
//
//    override func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
//        let (sut, loader) = makeSUT()
//
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [makeImage(), makeImage()])
//
//        let view0 = sut.simulateFeedImageViewVisible(at: 0)
//        let view1 = sut.simulateFeedImageViewVisible(at: 1)
//        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
//        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
//
//        loader.completeImageLoading(at: 0)
//        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
//        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
//
//        loader.completeImageLoadingWithError(at: 1)
//        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
//        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
//    }
//
//    override func test_feedImageView_rendersImageLoadedFromURL() {
//        let (sut, loader) = makeSUT()
//
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [makeImage(), makeImage()])
//
//        let view0 = sut.simulateFeedImageViewVisible(at: 0)
//        let view1 = sut.simulateFeedImageViewVisible(at: 1)
//        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
//        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
//
//        let imageData0 = UIImage.make(withColor: .red).pngData()!
//        loader.completeImageLoading(with: imageData0, at: 0)
//       // XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
//        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
//
//        let imageData1 = UIImage.make(withColor: .blue).pngData()!
//        loader.completeImageLoading(with: imageData1, at: 1)
//       // XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
//       // XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
//    }
//
//    override func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
//        let (sut, loader) = makeSUT()
//
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [makeImage(), makeImage()])
//
//        let view0 = sut.simulateFeedImageViewVisible(at: 0)
//        let view1 = sut.simulateFeedImageViewVisible(at: 1)
//        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
//        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
//
//        let imageData = UIImage.make(withColor: .red).pngData()!
//        loader.completeImageLoading(with: imageData, at: 0)
//        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
//        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
//
//        loader.completeImageLoadingWithError(at: 1)
//        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
//        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
//    }
//
//    override func test_feedImageViewRetryAction_retriesImageLoad() {
//        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
//        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
//        let (sut, loader) = makeSUT()
//
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [image0, image1])
//
//        let view0 = sut.simulateFeedImageViewVisible(at: 0)
//        let view1 = sut.simulateFeedImageViewVisible(at: 1)
//        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image URL request for the two visible views")
//
//        loader.completeImageLoadingWithError(at: 0)
//        loader.completeImageLoadingWithError(at: 1)
//        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action")
//
//        view0?.simulateRetryAction()
//        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected third imageURL request after first view retry action")
//
//        view1?.simulateRetryAction()
//        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected fourth imageURL request after second view retry action")
//    }
//
//    override func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
//        let (sut, loader) = makeSUT()
//
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [makeImage()])
//
//        let view = sut.simulateFeedImageViewVisible(at: 0)
//        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
//
//        let invalidImageData = Data("invalid image data".utf8)
//        loader.completeImageLoading(with: invalidImageData, at: 0)
//        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
//    }
//
//    override func test_feedImageView_preloadsImageURLWhenNearVisible() {
//        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
//        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
//        let (sut, loader) = makeSUT()
//
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [image0, image1])
//        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
//
//        sut.simulateFeedImageViewNearVisible(at: 0)
//        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first image is near visible")
//
//        sut.simulateFeedImageViewNearVisible(at: 1)
//        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
//    }
//
//    override func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
//        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
//        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
//        let (sut, loader) = makeSUT()
//
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [image0, image1])
//        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
//
//        sut.simulateFeedImageViewNotNearVisible(at: 0)
//        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once first image is not near visible anymore")
//
//        sut.simulateFeedImageViewNotNearVisible(at: 1)
//        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second image is not near visible anymore")
//    }
//
//    override func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
//        let (sut, loader) = makeSUT()
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [makeImage()])
//
//        let view = sut.simulateFeedImageViewNotVisible(at: 0)
//        loader.completeImageLoading(with: anyImageData())
//
//        XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
//    }

//    override func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
//        let (sut, loader) = makeSUT()
//
//        sut.loadViewIfNeeded()
//        loader.completeFeedLoading(with: [makeImage()])
//        _ = sut.simulateFeedImageViewVisible(at: 0)
//
//        let exp = expectation(description: "Wait for background queue")
//        DispatchQueue.global().async {
//            loader.completeImageLoading(with: self.anyImageData(), at: 0)
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 1.0)
//    }

    // MARK: HELPERS
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (controller:ListViewController,spy:LoaderSpy){
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader:loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut,loader)
    }

    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }

    private func makeComment(message: String = "any message",username:String = "a username") -> ImageComment {
        return ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
    }
    
    private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "comments count", file: file, line: line)
        
        let viewModel = ImageCommentsPresenter.map(comments)

        viewModel.comments.enumerated().forEach { index, comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, "date at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, "username at \(index)", file: file, line: line)
        }
    }
    
    private class LoaderSpy{
       
        // MARK: - FeedLoader

        private var requests = [PassthroughSubject<[ImageComment], Error>]()
        
        var loadCommentsCallCount:Int{
            requests.count
        }

        private(set) var  cancelledImageURLs = [URL]()
        
        private struct TaskSpy:FeedImageDataLoaderTask{
            let cancelCallBack:()->()
            func cancel() {
                cancelCallBack()
            }
        }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with comment:[ImageComment] = [],_ index:Int = 0){
           // completionArray[index](.success(feed))
            requests[index].send(comment)
        }
        
        func completeCommentsLoadingWithError(at index:Int = 0){
            let error = NSError(domain: "a error", code: 0)
           // completionArray[index](.failure(error))
            requests[index].send(completion: .failure(error))
        }
    }
}
