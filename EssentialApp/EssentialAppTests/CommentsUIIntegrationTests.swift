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

final class CommentsUIIntegrationTests: XCTestCase {

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
    
    func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        sut.simulateUserInitatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_deinit_cancelsRunningRequest() {
        var cancelCallCount = 0
        
        var sut: ListViewController?
        
        autoreleasepool {
            sut = CommentsUIComposer.commentsComposedWith(commentsLoader: {
                PassthroughSubject<[ImageComment], Error>()
                    .handleEvents(receiveCancel: {
                        cancelCallCount += 1
                    }).eraseToAnyPublisher()
            })
            
            sut?.loadViewIfNeeded()
        }
        
        XCTAssertEqual(cancelCallCount, 0)
        
        sut = nil
        
        XCTAssertEqual(cancelCallCount, 1)
    }
    
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
            requests[index].send(comment)
        }
        
        func completeCommentsLoadingWithError(at index:Int = 0){
            let error = NSError(domain: "a error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}
