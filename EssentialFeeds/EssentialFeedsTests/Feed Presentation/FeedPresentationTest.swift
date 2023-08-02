//
//  FeedPresentationTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 01/08/23.
//

import XCTest
import EssentialFeeds

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

protocol FeedLoadingView{
    func display(_ isLoading:FeedLoadingViewModel)
}

struct FeedLoadingViewModel{
    let isLoading:Bool
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
}

struct FeedViewsModel{
    let feed:[FeedImage]
}

protocol FeedView{
    func display(_ viewModel:FeedViewsModel)
}

final class FeedPresenter {
    
    private let errorView: FeedErrorView
    private let loadingView:FeedLoadingView
    private let feedView:FeedView
    
    init(errorView: FeedErrorView,
         loadingView:FeedLoadingView,
         feedView:FeedView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed:[FeedImage]){
        feedView.display(FeedViewsModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessageAndStartLoading() {
        let (sut, view) = makeSUT()
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none),
                                       .display(isLoading:true)])
    }
    
    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSUT()
        let feed = uniqueImageFeed().models
        
        sut.didFinishLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [
            .display(feed: feed),
            .display(isLoading: false)
        ])
    }
    
    // MARK: - Helpers
    
    private class ViewSpy:FeedErrorView,FeedLoadingView,FeedView {
      
        enum Message:Hashable{
            case display(errorMessage:String?)
            case display(isLoading:Bool)
            case display(feed:[FeedImage])
        }
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ isLoading: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: isLoading.isLoading))
        }
        
        func display(_ viewModel: FeedViewsModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view, loadingView: view, feedView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
}
