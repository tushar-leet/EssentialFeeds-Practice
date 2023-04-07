//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import XCTest
import EssentialFeeds

class RemoteFeedLoaderTest:XCTestCase{
    func test_init_doesNotLoadDataFromURL(){
        let (_,client) = makeSut()
        
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
    
    func test_load_requestsDataFromURL(){
        let url = URL(string: "Https://a-given-url.com")
        let (sut,client) = makeSut(url: url!)
        
        sut.load()
        
        XCTAssertEqual([url], client.requestedUrls)
    }
    
    func test_loadTwice_requestsDataFromURLTwice(){
        let url = URL(string: "Https://a-given-url.com")
        let (sut,client) = makeSut(url: url!)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual([url,url], client.requestedUrls)
    }
    
    func test_load_deliversErrorOnClientError(){
        let (sut,client) = makeSut()
        var capturedError = [RemoteFeedLoader.Error]()
        let clientError = NSError(domain: "Test", code: 0, userInfo: [:])

        sut.load{capturedError.append($0)}
        client.errors[0](clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    // MARK: Helpers
    private func makeSut(url:URL = URL(string: "Https://a-url.com")!) -> (remoteLoader:RemoteFeedLoader,client:HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client:client)
        return (sut,client)
    }
    
    private class HTTPClientSpy:HTTPClient{
        
        var requestedURL:URL?
        var requestedUrls = [URL]()
        var errors = [(Error) -> Void]()
        
        func get(url: URL, completion: @escaping (Error) -> Void) {
            errors.append(completion)
            self.requestedURL = url
            requestedUrls.append(url)
        }
    }
}
