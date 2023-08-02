//
//  FeedPresentationTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 01/08/23.
//

import XCTest

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

final class FeedPresenter {
    
    private let errorView: FeedErrorView
    private let loadingView:FeedLoadingView
    
    init(errorView: FeedErrorView,
         loadingView:FeedLoadingView) {
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
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
    
    // MARK: - Helpers
    
    private class ViewSpy:FeedErrorView,FeedLoadingView {
       
        enum Message:Hashable{
            case display(errorMessage:String?)
            case display(isLoading:Bool)
        }
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ isLoading: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: isLoading.isLoading))
        }
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view, loadingView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
}
