//
//  LoadResourcePresenterTests.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 16/09/23.
//

import XCTest
import EssentialFeeds

final class LoadResourcePresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoading_displaysNoErrorMessageAndStartLoading() {
        let (sut, view) = makeSUT()
        sut.didStartLoading()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none),
                                       .display(isLoading:true)])
    }
    
    func test_didFinishLoadingResource_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSUT(mapper:{resource in resource + " view model"})

        sut.didFinishLoading(with: "resource")
        
        XCTAssertEqual(view.messages, [
            .display(resourceViewModel: "resource view model"),
            .display(isLoading: false)
        ])
    }
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
            .display(isLoading: false)
        ])
    }

    // MARK: - Helpers
    
    private class ViewSpy:FeedErrorView,ResourceView,FeedLoadingView {
       typealias ResourceViewModel = String
        enum Message:Hashable{
            case display(errorMessage:String?)
            case display(isLoading:Bool)
            case display(resourceViewModel:String)
        }
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ isLoading: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: isLoading.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resourceViewModel: viewModel))
        }
    }
    
    private typealias SUT = LoadResourcePresenter<String,ViewSpy>
    private func makeSUT(
        mapper:@escaping SUT.Mapper = {_ in "any"},
        file: StaticString = #file,
        line: UInt = #line) -> (sut: SUT, view: ViewSpy) {
        let view = ViewSpy()
            let sut = LoadResourcePresenter(errorView: view, loadingView: view, resourceView: view,mapper:mapper)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: SUT.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
