//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import XCTest

class RemoteFeedLoader{
    
    let client:HTTPClient
    let url:URL
    
    init(url:URL,client:HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(){
        client.get(url: url)
    }
}

protocol HTTPClient{
    func get(url:URL)
}

class RemoteFeedLoaderTest:XCTestCase{
    func test_init_doesNotLoadDataFromURL(){
        let (_,client) = makeSut()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let url = URL(string: "Https://a-given-url.com")
        let (sut,client) = makeSut()
        
        sut.load()
        
        XCTAssertEqual(url, client.requestedURL)
    }
    
    // MARK: Helpers
    private func makeSut(url:URL = URL(string: "Https://a-url.com")!) -> (remoteLoader:RemoteFeedLoader,client:HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client:client)
        return (sut,client)
    }
    
    private class HTTPClientSpy:HTTPClient{
        var requestedURL:URL?
        
        func get(url:URL){
            requestedURL = url
        }
    }
}
